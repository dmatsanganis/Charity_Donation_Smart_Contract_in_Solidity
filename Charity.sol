pragma solidity ^ 0.4.25;

contract Charity {
    uint numOfContributors; // number of donators for the charity
    uint goal; // goal amount for the charity
    uint minAmount; // minimum amoumt of each donation
    uint endDate; // end date of the charity
    address admin; // address of the admin that created the charity
    mapping(address=>uint) public contributions; // mapping of contributions containing the address and the donation value for each donator

    // struct for spending request
    struct Spending {
        string description; // description of the spending request
        address recipient; // address of the reciever 
        uint amount; // amount that is going to be spent
        uint numOfVoters; // number of voters
        bool completed; // bool variable for the completion of the spending request
        mapping(address=>bool) voters; // mapping of voter containing the address and the vote result for each voter
    }
    
    // array for all the spending requests 
    Spending[] public spendings;
    
    // constructor for the charity with two parameter, one for the end date and one for the goal
    constructor(uint _endDate, uint _goal) public payable{
        endDate = _endDate; // set the end date of the charity equal with the end date parameter 
        goal = _goal; // set the goal of the charity equal with the goal parameter 
        minAmount = _goal/25; // set the minimum donation amount equal with the  of the goal
        admin = msg.sender; // set the address of the admin equal with the sender address
    }
    
    // function for the contribution of a donator
    function contribute() public payable {
        require(msg.value >= minAmount, "You try to send less than the minimum donation amount"); // require that the donator is more or equal from the minimum donation
        require(block.timestamp < endDate, "Donation has expired"); // require that charity didn't expire
        if (contributions[msg.sender] == 0)  // if the donator had not already contibute to the charity
        {
            numOfContributors++; // add one to the number of contributors
        }
        contributions[msg.sender] += msg.value; // add the value to the sender's donations
    }
    
    // function for the refund of a donator
    function refund() public {
        require(block.timestamp > endDate, "Charity haven't expire yet"); // require that charity expired
        require(getMoneyRaised() < goal, "Charity reached the goal"); // require that charity didn't reach the goal
        require(contributions[msg.sender] > 0, "You haven't contibute to the charity"); // require that the sender contibuted to the charity
        msg.sender.transfer(contributions[msg.sender]); // transfer back the amount the contributor had donated
        numOfContributors--; // remove one from the number of contributors
        contributions[msg.sender] = 0; // set 0 the amount of donation for the sender's address
    }
    
    // function for the voting of a donator
    function vote(uint index) public {
        Spending storage spending = spendings[index];
        require(getMoneyRaised() >= goal, "Charity didn't reach the goal yet"); // require that charity reached the goal
        require(contributions[msg.sender] > 0, "You haven't contibute to the charity"); // require that the sender contibuted to the charity
        require(spending.voters[msg.sender] == false, "You have already voted for this spending request"); // require that the sender hadn't already vote
        spending.voters[msg.sender] = true; // set true the vote result for the sender's address
        spending.numOfVoters++; // add one to the number of voters
    }

    // function for starting a spending request from the admin
    function startSpending(string _description, address _recipient, uint _amount) public {
        require(msg.sender == admin, "Only admin can start a spending request"); // require that the sender is the admin of the charity
        require(getMoneyRaised() >= goal, "Charity didn't reach the goal yet"); // require that charity reached the goal
        // create a new spending request with the parameters passed to the function
        Spending memory spending = Spending(
            {
                description: _description,
                amount: _amount,
                recipient: _recipient,
                numOfVoters: 0,
                completed: false
                }
            );
        spendings.push(spending); // add the spending request to the array
    }
    
    // function that completes the spending request
    function makePayment(uint index) public {
        Spending storage spending = spendings[index]; // retrieve from the memory the spending request with the index passed 
        require(spending.completed == false, "This spending request is already completed"); // require that the selected spending request is not completed
        require(msg.sender == admin, "Only admin can make the payment"); // require that tne sender is the admin
        require(spending.numOfVoters > numOfContributors / 2, "Not enough contributors voted for the spending request"); // require that more than 50% of the contributors voted
        require(getMoneyRaised() >= goal, "Charity didn't reach the goal yet"); // require that charity reached the goal
        require(getMoneyRaised() >= spending.amount, "Charity don't have enough amount"); // require that charity have the amount
        spending.recipient.transfer(spending.amount); // transfer the spending amount to the recipient
        spending.completed = true; // set the spending request as completed 
    }
    
    // function that returns the money raised for the charity
    function getMoneyRaised() public view returns(uint)
    {
        return address(this).balance;
    }
    
    // function that returns the number of contributors
    function getNumOfContributors() public view returns(uint)
    {
        return numOfContributors;
    }
    
     // function that returns the goal of the charity
    function getGoal() public view returns(uint)
    {
        return goal;
    }
    
    // function that returns the minimum donation amount
    function getMinAmount() public view returns(uint)
    {
        return minAmount;
    }
    
    // function that return the end date of the charity
    function getEndDate() public view returns(uint)
    {
        return endDate;
    }
    
    // function that returns the address of the admin that created the charity
    function getAdminAddress() public view returns(address)
    {
        return admin;
    }
}