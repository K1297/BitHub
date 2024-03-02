// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Bithub is IERC20 {
    string public name = "Bithub";
    string public symbol = "BTH";
    uint8 public decimals = 18;
    uint256 public totalSupply;

    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    constructor(uint256 _initialSupply) {
        totalSupply = _initialSupply * 10 ** uint256(decimals);
        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) external view override returns (uint256) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) external override returns (bool) {
        require(_to != address(0), "Invalid address");
        require(_value <= balances[msg.sender], "Insufficient balance");

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external override returns (bool) {
        require(_from != address(0) && _to != address(0), "Invalid addresses");
        require(_value <= balances[_from], "Insufficient balance");
        require(_value <= allowed[_from][msg.sender], "Allowance exceeded");

        balances[_from] -= _value;
        balances[_to] += _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external override returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) external view override returns (uint256) {
        return allowed[_owner][_spender];
    }
}

contract ContributionTracker {
    struct Contribution {
        address developer;
        string repositoryUrl;
        string contributionType;
        uint256 timestamp;
        uint256 amount; // Reward amount associated with the contribution
        bool rewarded; // Flag to indicate if the contribution has been rewarded
    }

    mapping(address => Contribution[]) public developerContributions;

    address public owner; // Owner of the contract
    mapping(address => bool) public approvedContributors; // Approved contributors allowed to record contributions
    
    uint256 public baseReward = 100 ether; // Base reward for contributions
    uint256 public bonusReward = 50 ether; // Bonus reward for high-quality contributions
    uint256 public constant MAX_REWARD_TIER = 3; // Maximum reward tier
    
    uint256 public totalRewards; // Total rewards available for distribution
    uint256 public totalStaked; // Total amount staked by users
    mapping(address => uint256) public stakedBalances; // Staked balances of users
    
    mapping(address => bool) public governors; // Governors with the authority to adjust parameters
    uint256 public rewardAdjustmentCooldown; // Cooldown period for adjusting reward parameters
    uint256 public lastAdjustmentTime; // Timestamp of the last reward adjustment
    
    Bithub public bithubToken; // Bithub ERC20 token contract

    event ContributionRecorded(
        address indexed developer,
        string repositoryUrl,
        string contributionType,
        uint256 timestamp,
        uint256 amount
    );

    event RewardClaimed(
        address indexed developer,
        uint256 amount
    );

    event RewardParametersAdjusted(
        uint256 baseReward,
        uint256 bonusReward
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    modifier onlyApprovedContributors() {
        require(approvedContributors[msg.sender], "You are not an approved contributor");
        _;
    }

    modifier onlyGovernors() {
        require(governors[msg.sender], "Only governors can perform this action");
        _;
    }

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        governors[msg.sender] = true;
        bithubToken = new Bithub(_initialSupply); // Deploy Bithub token contract
    }

    function approveContributor(address _contributor) external onlyOwner {
        approvedContributors[_contributor] = true;
    }

    function removeContributor(address _contributor) external onlyOwner {
        approvedContributors[_contributor] = false;
    }

    function recordContribution(
        string memory _repositoryUrl,
        string memory _contributionType
    ) external onlyApprovedContributors {
        require(bytes(_repositoryUrl).length > 0, "Repository URL cannot be empty");
        require(bytes(_contributionType).length > 0, "Contribution type cannot be empty");

        uint256 rewardAmount = calculateReward();

        Contribution memory newContribution = Contribution({
            developer: msg.sender,
            repositoryUrl: _repositoryUrl,
            contributionType: _contributionType,
            timestamp: block.timestamp,
            amount: rewardAmount,
            rewarded: false
        });

        developerContributions[msg.sender].push(newContribution);
        totalRewards += rewardAmount;

        emit ContributionRecorded(
            msg.sender,
            _repositoryUrl,
            _contributionType,
            block.timestamp,
            rewardAmount
        );
    }

    function calculateReward() private view returns (uint256) {
        // For simplicity, let's assume the reward tier is determined randomly here
        uint256 rewardTier = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % MAX_REWARD_TIER + 1;

        if (rewardTier == 1) {
            return baseReward;
        } else if (rewardTier == 2) {
            return baseReward + bonusReward;
        } else {
            return baseReward + 2 * bonusReward;
        }
    }

    function getDeveloperContributions(address _developer) external view returns (Contribution[] memory) {
        return developerContributions[_developer];
    }

    function claimReward() external {
        uint256 totalReward;
        Contribution[] storage contributions = developerContributions[msg.sender];

        for (uint256 i = 0; i < contributions.length; i++) {
            if (!contributions[i].rewarded) {
                totalReward += contributions[i].amount;
                contributions[i].rewarded = true;
            }
        }

        require(totalReward > 0, "No rewards to claim");

        bithubToken.transfer(msg.sender, totalReward); // Transfer Bithub tokens
        totalRewards -= totalReward;

        emit RewardClaimed(msg.sender, totalReward);
    }

    function adjustRewardParameters(uint256 _baseReward, uint256 _bonusReward) external onlyGovernors {
        require(block.timestamp - lastAdjustmentTime >= rewardAdjustmentCooldown, "Cooldown period has not elapsed");
        
        baseReward = _baseReward;
        bonusReward = _bonusReward;
        lastAdjustmentTime = block.timestamp;

        emit RewardParametersAdjusted(baseReward, bonusReward);
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "Invalid staking amount");

        bithubToken.transferFrom(msg.sender, address(this), _amount); // Transfer Bithub tokens to contract
        stakedBalances[msg.sender] += _amount;
        totalStaked += _amount;
    }

    function unstake(uint256 _amount) external {
        require(_amount > 0 && stakedBalances[msg.sender] >= _amount, "Invalid unstaking amount");

        bithubToken.transfer(msg.sender, _amount); // Transfer Bithub tokens to user
        stakedBalances[msg.sender] -= _amount;
        totalStaked -= _amount;
    }

    function withdrawFunds(uint256 _amount) external onlyOwner {
        require(_amount <= address(this).balance - totalRewards, "Insufficient funds available for withdrawal");

        payable(owner).transfer(_amount);
    }
}
