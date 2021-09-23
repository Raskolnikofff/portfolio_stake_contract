pragma solidity 0.8.7;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Stake is AccessControl {
    uint256 public validityPeriod;
    uint256 public accrualPeriod;
    uint256 public claimTime;
    uint256 public withdrawalBPTTime;
    IERC20 public BPTtokens;
    IERC20 public rewardToken;
    uint256 public periodsNumber;
    uint256 public startTime;
    uint256 public amountRewards;

    constructor(
        uint256 _validityPeriod,
        uint256 _accrualPeriod,
        uint256 _withdrawalBPTTime,
        IERC20 _BPTtokens,
        IERC20 _rewardToken
    ) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        startTime = block.timestamp;
        validityPeriod = _validityPeriod * 1 days;
        accrualPeriod = _accrualPeriod * 1 days;
        claimTime = block.timestamp + validityPeriod;
        withdrawalBPTTime = _withdrawalBPTTime * 1 days;
        BPTtokens = _BPTtokens;
        rewardToken = _rewardToken;

        uint256 prePeriod = _validityPeriod / _accrualPeriod;
        periodsNumber = (_validityPeriod - prePeriod * _accrualPeriod) > 0 ? prePeriod + 1 : prePeriod;
    }

    struct DepositParams {
        uint256 amount;
        uint256 depositTime;
        bool isRewarded;
    }

    struct PeriodParams {
        uint256 total;
        bool isWithdrawAll;
    }

    uint256 totalBPT;

    mapping(uint256 => PeriodParams) period;
    mapping(uint256 => mapping(address => PeriodParams)) periodUser;
    mapping(address => DepositParams) public userDeposit;

    function deposit(uint256 _amount) external {
        require(block.timestamp < claimTime, "deposit: deposit closed");
        uint256 periodNumber = currentPeriodNumber();
        totalBPT += _amount;
        period[periodNumber].total = totalBPT;
        userDeposit[msg.sender].amount += _amount;
        userDeposit[msg.sender].depositTime = block.timestamp + withdrawalBPTTime;
        periodUser[periodNumber][msg.sender].total = userDeposit[msg.sender].amount;

        // TODO: do safeTransferFrom?
        BPTtokens.transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawBPT(uint256 _amount) external {
        require(block.timestamp > userDeposit[msg.sender].depositTime, "withdrawBPT:blocking period not passed");
        require(_amount <= userDeposit[msg.sender].amount, "withdrawBPT:amount more deposited tokens");
        uint256 periodNumber = currentPeriodNumber();
        userDeposit[msg.sender].amount -= _amount;
        periodUser[periodNumber][msg.sender].total = userDeposit[msg.sender].amount;

        totalBPT -= _amount;
        period[periodNumber].total = totalBPT;
        if (totalBPT == 0) {
            period[periodNumber].isWithdrawAll = true;
        }

        if (userDeposit[msg.sender].amount == 0) {
            periodUser[periodNumber][msg.sender].isWithdrawAll = true;
        }

        BPTtokens.transfer(msg.sender, _amount);
    }

    function withdrawRewards() external {
        require(block.timestamp > claimTime, "withdrawRewards: claimTime not passed");
        require(!userDeposit[msg.sender].isRewarded, "withdrawRewards: reward already been withdrawn");
        uint256 userReward = _rewardCalc(msg.sender);
        userDeposit[msg.sender].isRewarded = true;
        rewardToken.transfer(msg.sender, userReward);
    }

    function withdrawUnusedRewards() external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(block.timestamp > claimTime, "withdrawUnusedRewards: claimTime not passed");
        require(!userDeposit[msg.sender].isRewarded, "withdrawRewards: reward already been withdrawn");
        uint256 countNoDeposit;
        bool isWithdrawAllPeriod;
        uint256 periodTotal;
        for (uint256 i; i < periodsNumber; i++) {
            if (period[i].total != 0) {
                periodTotal = period[i].total;
                isWithdrawAllPeriod = false;
            } else {
                if (period[i].isWithdrawAll) {
                    isWithdrawAllPeriod = true;
                }
                if (isWithdrawAllPeriod) {
                    countNoDeposit++;
                }
            }
        }
        userDeposit[msg.sender].isRewarded = true;
        uint256 unusedRewards = (amountRewards / periodsNumber) * countNoDeposit;
        rewardToken.transfer(msg.sender, unusedRewards);
    }

    function _rewardCalc(address _account) internal view returns (uint256) {
        uint256 userReward;
        bool isWithdrawAllPeriod;
        uint256 periodTotal;
        for (uint256 i; i < periodsNumber; i++) {
            if (period[i].total != 0) {
                periodTotal = period[i].total;
                isWithdrawAllPeriod = false;
                userReward += _calc(_account, i);
            } else {
                if (period[i].isWithdrawAll) {
                    isWithdrawAllPeriod = true;
                }
                if (!isWithdrawAllPeriod && periodTotal != 0) {
                    userReward += _calc(_account, i);
                }
            }
        }
        return userReward;
    }

    function _calc(address _account, uint256 i) internal view returns (uint256) {
        uint256 userReward;
        bool isWithdrawAll;
        uint256 BPT;
        uint256 periodTotal;
        uint256 amount = periodUser[i][_account].total;
        if (amount != 0) {
            BPT = amount;
            isWithdrawAll = false;
            userReward += ((amountRewards / periodsNumber) * BPT) / periodTotal;
        } else {
            if (periodUser[i][_account].isWithdrawAll) {
                isWithdrawAll = true;
            }
            if (!isWithdrawAll && BPT != 0) {
                userReward += ((amountRewards / periodsNumber) * BPT) / periodTotal;
            }
        }
        return userReward;
    }

    function totalDepositTokens() external view returns (uint256) {
        uint256 periodNumber = currentPeriodNumber() > periodsNumber ? periodsNumber : currentPeriodNumber();
        return period[periodNumber].total;
    }

    function depositRewards(uint256 _amount) external {
        require(block.timestamp <= claimTime, "withdrawRewards: claimTime passed");
        amountRewards += _amount;
        rewardToken.transferFrom(msg.sender, address(this), _amount);
    }

    function currentPeriodNumber() public view returns (uint256) {
        return (block.timestamp - startTime) / accrualPeriod;
    }
}
