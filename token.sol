pragma solidity ^0.4.20;

library SafeMath // �����÷ο츦 �����ϱ� ���� SafeMath �Լ�, mul,div,sub,add �� 4���� �Լ��� ���ǵǾ� �ִ�.
{
    function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256)
    {
        assert(b <= a);

        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);

        return c;
    }
}

contract OwnerHelper // public���� �����Ǿ� �ִ� �Լ� �߿� �����ڸ� ���� ������ �Լ��� ����� ��
{
    address public owner; // �� ����� ������ ����� �ּ�

    event OwnerTransferPropose(address indexed _from, address indexed _to); // �����ڸ� ������ ��츦 ����� OwnerTransferPropose �̺�Ʈ ����

    modifier onlyOwner // onlyOwner�� ������ function �Լ��� ���̻�� ���̰� �� ��� �ش� function�� ���� �ϱ� ���� modifier onlyOwner�� ����� ������ ����

    {
        require(msg.sender == owner); // �� �Լ��� owner(������)�� ����� �� �ֵ��� ����
        _; // onlyOwner�Լ��� ������ �ȵǸ� �� �ش� �Լ� function �� �����ϴ� ����� �����ڰ� �ƴϸ� function �Լ��� ������ �Ұ����ϰ� ���� ��
    }

    function OwnerHelper () public // ������ 
    {
        owner = msg.sender; 
    }

    function transferOwnership(address _to) onlyOwner public
    {
        require(_to != owner);  // �����ڸ� �����Ϸ��� ����� �̹� �������̸� �ȵǱ� ������ require�� �˻� 
        require(_to != address(0x0)); 
        owner = _to;
        OwnerTransferPropose(owner, _to);
    }
}

contract ERC20Interface // ���ο� ��Ʈ��Ʈ�� ERC20Interface ��Ʈ��Ʈ �־����� �̺�Ʈ�� �Լ��� �̴����򿡼� �����ϴ� �Լ� 
                     // event�� Ʈ����� ���� �ȿ� log�� ����� �Լ� 
                     // ��Ʈ��Ʈ�� ������ ���(msg.sender)�� owner�� ���� ���� Ư�� �Լ��� �����ڸ� ��� �ϵ��� ������ �� �̴�.
{
    event Transfer( address indexed _from, address indexed _to, uint _value); // Transfer�� ��ū�� �̵��� ���� ������ ����� �α�
    event Approval( address indexed _owner, address indexed _spender, uint _value); // Approval�� approve�Լ��� ���� ������ �� �� ����� �α�
   
    function totalSupply() constant public returns (uint _supply); // �ش� ����Ʈ ��Ʈ��Ʈ ��� ERC-20 ��ū�� �� ���෮ Ȯ��
    function balanceOf( address _who ) constant public returns (uint _value); // owner�� ������ �ִ� ��ū�� ������ Ȯ�� 
    function transfer( address _to, uint _value) public returns (bool _success); // ��ū�� ���� 
    function approve( address _spender, uint _value ) public returns (bool _success); // ��ū�� ���� ���� �ϵ��� spender(�ŷ���)���� �絵�� ��ū�� ���� ����
    function allowance( address _owner, address _spender ) constant public returns (uint _allowance); // owner�� spender(�ŷ���)���� �絵 ������ ��ū�� ���� Ȯ��
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success); // spender(�ŷ���)�� �ŷ� �����ϵ��� �絵 ���� ��ū�� _to(����)���� ����
}

contract HyunJaeToken is ERC20Interface, OwnerHelper // SimpleToken�� ERC20Interface �� OwnerHelper�� ����Ͽ� ERC20Interface �� OwnerHelper �Լ��� ��밡���ϰ� ��
                                                     // HyunJaeToken�̶�� �ϳ��� ��Ʈ��Ʈ ����, �ؿ� ��Ʈ��Ʈ ������ ����� ������ ���ؼ� �̸��� ���� 
{
    using SafeMath for uint256; // SafeMath ���̺귯�� �Լ��� ���� ���� �ۼ���
    
    string public name; // ��Ʈ��Ʈ�� ������ ��ū�� �̸�
    uint public decimals; // ��ū�� �Ҽ��� �Ʒ� �ڸ���
    string public symbol; // ��ū �̸��� ���Ӹ�
    uint public totalSupply; // ��ū�� �� ���෮
    address public wallet; // 0x�� �����ϴ� 42�ڸ��� String�� ������ �ּ�
    
    uint public maxSupply;
    uint public mktSupply;
    uint public devSupply;
    uint public saleSupply;

    uint public tokenIssuedSale; // �Ǹ��� ��ū�� ��    
    uint public tokenIssuedMkt; // ȸ�� ������ ���
    uint public tokenIssuedDevelop; // ���� ���

    uint public saleEtherReceived;

    uint public saleTokenLeft;
    
    uint public burnRatio = 0;
    
    uint private E18 = 1000000000000000000; // �Ҽ��� �Ʒ� �ڸ����� ������ ����ϱ� ���� 0�� 18�� �� ����, �ִ� �Ҽ��� �Ʒ��� 18���� 0�� ���θ�ŭ �ɰ��� ��ȯ�� �� �ֱ� �����̴�
    uint public ethPerToken = 4000; // 1�̴��� ������ �ּ��� ��ū�� �� 
    uint public privateSaleBonus = 50;
    uint public preSalePrimaryBonus = 30;
    uint public presaleSecondBonus = 20;
    uint public crowdSalePrimaryBonus = 10;
    uint public crowdSaleSecondBonus = 0;

    uint public privateSaleStartDate; // �����̺� ���� ���� ��¥
    uint public privateSaleEndDate; // �����̺� ���� ���� ��¥
    
    uint public preSalePrimaryStartDate; // ���� ���� 1�� ���� ��¥
    uint public preSalePrimaryEndDate; //   ���� ���� 1�� ���� ��¥
    
    uint public preSaleSecondStartDate; // ���� ���� 2�� ���� ��¥
    uint public preSaleSecondEndDate; //   ���� ���� 2�� ���� ��¥
    
    uint public crowdSalePrimaryStartDate; // ũ���� ���� 1�� ���� ��¥
    uint public crowdSalePrimaryEndDate; //   ũ���� ���� 1�� ���� ��¥
    
    uint public crowdSaleSecondStartDate; // ũ���� ���� 2�� ���� ��¥
    uint public crowdSaleSecondEndDate; //   ũ���� ���� 2�� ���� ��¥
    
    bool public tokenLock; // ��ū�� ���� �� ��ū�� �̵��� �����Ͽ� �̵��� �Ұ��� �ϵ��� �մϴ�.
    
    mapping (address => uint) internal balances; // �ش� ��ū�� �����ϰ� �ִ� ������ �� �Ǵ� �������� ��ū ������ ����� Ȯ���ϴµ� ���  Key : address, Value : uint
    mapping (address => mapping ( address => uint )) internal approvals; // Key : Owner�� address, Value(Key : Spender(�ŷ���)�� address, Value : �ŷ��ҿ� �ðܵ� Token�� ����)

    mapping (address => bool) internal personalLock;
    mapping (address => uint) internal icoEtherContributeds; // ������ ICO�� ������ �̴��� ����
    
    event BurnToken(uint saleSupply, uint devSupply, uint mktSupply);    
    event RemoveLock(address indexed _who); // �� ���� �̺�Ʈ
    event WithdrawMkt(address indexed _to, uint _value); // ȸ�� ��� �̺�Ʈ

    function HyunJaeToken () public // function�� ��Ʈ��Ʈ ������ ���Ǵ� �Լ��̸� �����ڴ� ������ ���ÿ� �ٷ� ����
    {
        name = "HyunJaeToken"; // ��ū�� �̸� HyunjaeToken
        decimals = 18; // ��ū�� �Ҽ��� �Ʒ� �ڸ� ���� 18�ڸ�
        symbol = "HJ"; // ��ū �̸��� ���Ӹ��� HJ
        totalSupply = 0; // ��ū�� �ѹ��෮�� 0���� �ʱ�ȭ
   
       wallet = msg.sender; // ��Ʈ��Ʈ�� �����ϴ� ����� �ּҸ� ����
   
       maxSupply = 100000000 * E18;
        mktSupply =  20000000 * E18;
        devSupply = 20000000 * E18;
        saleSupply = 60000000 * E18;

        tokenIssuedSale = 0;
        tokenIssuedMkt = 0;
        tokenIssuedDevelop = 0;
        
       saleEtherReceived = 0; // �Ǹŷ� ������ �̴��� ������ ����
    
        tokenLock = true;
         
        privateSaleStartDate = 1529593200; // 2018-06-22
        privateSaleEndDate = 1530198000; // 2018-06-29
    
        preSalePrimaryStartDate = 1530284400; // 2018-06-30
        preSalePrimaryEndDate = 1530889200; // 2018-07-07
    
        preSaleSecondStartDate = 1530975600; // 2018-07-08
        preSaleSecondEndDate = 1531580400; // 2018-07-15
    
        crowdSalePrimaryStartDate = 1531666800; // 2018-07-16
        crowdSalePrimaryEndDate = 1532271600; // 2018-07-23
    
        crowdSaleSecondStartDate = 1532358000; // 2018-07-24
        crowdSaleSecondEndDate = 1532962800; // 2018-07-31
    }
    
    function atNow() public constant returns(uint) 
    {
        return now; // �ָ���Ƽ ���ο����� ����ð��� now�� �޾ƿ� �� ����
    }
    
    function () payable public // �Լ� ȣ���� ���ؼ� �̴��� ������ ���� ������ ��
    {
        buyToken();
    }
    
    function buyToken() private
    {
        require(saleSupply > tokenIssuedSale); // �ǸŸ� �� ��ū ������ �Ǹŵ� ��ū ������ �˻� �� �ǸŸ� �� ��ū�� ���� �Ǹŵ� ���� ��ū���� ���Ƽ��� �ȵǰ�                     // ������ Ŀ�ߵȴ�. require �Լ��� ��� �ߴٴ� ���� �Ǹ��� �� �ִ� ��ū�� ���� �����Ѵٴ� ���� �ǹ�
        
        uint saleType = 0;   // 1 : Private , 2 : 1�� Pre  , 3 : 2�� Pre  , 4 : 1�� Crowd , 5 : 2�� Crowd
        uint saleBonus = 0;  // �����̺�, ����, ũ���� �� �ð��� �´� �Ǹ� ���ʽ� ����

       uint minEth = 1 ether; // �ŷ��� �����ϱ� ���� ����ڰ� �����־�� �� �ּ� �̴��� ��: 0
       uint maxEth = 300 ether; // �ŷ��� ������ ����Ҽ� �ִ� ������ �ִ� �̴��� �� : 300ether
        
        uint nowTime = atNow(); // ���� �ð��� ����

        if(nowTime >= privateSaleStartDate && nowTime < privateSaleEndDate)
        {
            saleType = 1;
            saleBonus = privateSaleBonus;
        }
        else if(nowTime >= preSalePrimaryStartDate && nowTime < preSalePrimaryEndDate)
        {
            saleType = 2;
            saleBonus = preSalePrimaryBonus;
        }
        else if(nowTime >= preSaleSecondStartDate && nowTime < preSaleSecondEndDate)
        {
            saleType = 3;
            saleBonus = presaleSecondBonus;
        }
         else if(nowTime >= crowdSalePrimaryStartDate && nowTime < crowdSalePrimaryEndDate)
        {
            saleType = 4;
            saleBonus = crowdSalePrimaryBonus;
        }
        else if(nowTime >= crowdSaleSecondStartDate && nowTime < crowdSaleSecondEndDate)
        {
            saleType = 5;
            saleBonus = crowdSaleSecondBonus;
        }
        
        require (saleType >= 1 && saleType <= 5);   /* �� �ڵ�� ���� �ð��� �´� ���� ����(�����̺�,����,ũ����) �� �Ǹ� ���ʽ� ����*/

        require (msg.value >= minEth && icoEtherContributeds[msg.sender].add(msg.value) <= maxEth);    // ��Ʈ��Ʈ�� ������ ����� �̴��� ���� �ּ��� �̴���(0)���� ���� ������ ICO�� ������ �̴��� ������ �ִ��̴��� ��(300)���� �۰ų� ������ Ȯ��
   
        uint tokens = ethPerToken.mul(msg.value); // ��Ʈ��Ʈ ������ ����� ������ �̴�(msg.value)�� ������ �´� ��ū�� ���� ����
        tokens = tokens.mul(100 + saleBonus) / 100; // ��ū�� ���� * �ŷ��� ������ �ð����� �Ǹ� ���ʽ� 
        
        require (saleSupply >= tokenIssuedSale.add(tokens)); // �ǸŸ� �� ��ū�� ��� �Ǹ��� ��ū�� ���� ��

        tokenIssuedSale = tokenIssuedSale.add(tokens); // �Ǹ��� ��ū�� ���� ����
       totalSupply = totalSupply.add(tokens); // ��ū�� �� ���෮�� �Ǹ��� ��ū�� ���� ����
       saleEtherReceived = saleEtherReceived.add(msg.value); // ���� �̴��� ���� ���� 
       
       balances[msg.sender] = balances[msg.sender].add(tokens); // ��Ʈ��Ʈ�� ������ ����� ��ū�� ������ �÷���(��ū ����)
       icoEtherContributeds[msg.sender] = icoEtherContributeds[msg.sender].add(msg.value); // ��Ʈ��Ʈ�� ������ ������ ICO�� ������ �̴��� ���� ������
       personalLock[msg.sender] = true; // ���ζ��� �ɾ���

        Transfer(0x0, msg.sender, tokens); // ��ū�� �̵��� ������ �̺�Ʈ(�α�)�� ���
        
        wallet.transfer(address(this).balance);  

    }

    function isTokenLock(address _from, address _to) constant public returns (bool _success) 
    {
       _success = false;
   
       if (tokenLock == true)
       {
          _success = true;
       }
   
       if (personalLock[_from] == true || personalLock[_to] == true )
       {
          _success = true;
       }
   
       return _success;
    }

    function isPeronalLock(address _who) constant public returns (bool)
    {
        return personalLock[_who];
    }
    
    function removeTokenLock() onlyOwner public
    {
        require(tokenLock == true);
        
        tokenLock = false;

       RemoveLock(0x0);
    }

    function removePersonalTokenLock(address _person) onlyOwner public 
    {
       require(personalLock[_person] == true);
   
        personalLock[_person] = false;
   
       RemoveLock(_person);
    }

    function totalSupply() constant public returns (uint)
    { 
        return totalSupply; // �� ���෮ ���� ��ȯ�� ��    
    }
    
    function balanceOf(address _who) constant public returns (uint) 
    {
        return balances[_who]; // mapping �� ���� balances���� �Է��� address�� _who�� ������ �ִ� ��ū�� ���� ������
    }
    
    function transfer(address _to, uint _value) public returns (bool) 
    {
        require(balances[msg.sender] >= _value); // ��ū �̵��� ������ ���(msg.sender)�� �̵��� ��û�� ��(_value)���� ���� ��ū�� ������ �־�� ��(require�� �˻�)
        require(isTokenLock(msg.sender,_to) == true);
        
        balances[msg.sender] = balances[msg.sender].sub(_value); // ���� ���� ��ū�� �������� ��ū�� ������ŭ ����
        balances[_to] = balances[_to].add(_value); // ������ ��ū ������ ������ŭ �����ش�.
        
        Transfer(msg.sender, _to, _value); // event�Լ��� Transfer�� ���
        
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool)
    {
        require(balances[msg.sender] >= _value); // ������ ���(_msg.sender)�� ��ū ������ �ñ� ������ ���� ������ �־�� ��(require�� �˻�)
        
        approvals[msg.sender][_spender] = _value; // ���� ���� �ñ� ����(_spender)���� �ñ� ��(_value)�� approvals�� ���� ����
        
        Approval(msg.sender, _spender, _value); // event�Լ��� Approval�� ���
        
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint) 
    {
        return approvals[_owner][_spender]; // �Է��� �ΰ��� �ּҰ��� ���� approvals�� ����
    }
    
    function transferFrom(address _from, address _to, uint _value) public returns (bool) // �ŷ� ������(spender)�� Owner(_from)�� ������� ��ŭ Buyer(_to)���� ��ū�� ����
    {
        require(balances[_from] >= _value); // Owner(_from)�� ������ �ִ� ��ū�� ������ �Է��� ��ū�� �������� ���ƾ���(require�� �˻�)
        require(approvals[_from][msg.sender] >= _value); // �����ڿ��� Owner�� ������� ��ū�� ���� ���� �Է��� ��ū�� �������� ���ƾ� ��(require�� �˻�)    
        require(isTokenLock(_from,_to) == true); 
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value); // �����ڿ��� ����� ��ū�� ������ �Է��� ��ū�� �������� ����
        balances[_from] = balances[_from].sub(_value); // ���� ������ �ִ� ��ū�� ������ �Է��� ��ū�� �������� ����
        balances[_to]  = balances[_to].add(_value); // ������ ��ū ������ �Է��� ��ū�� ������ŭ ������
        
        Transfer(_from, _to, _value); // event�Լ��� Transfer�� ���
        
        return true;
    }
    
    function minMktTokens(address _to, uint _value) public onlyOwner 
    {
        require(mktSupply > tokenIssuedMkt);
        require(mktSupply > tokenIssuedMkt.add(_value));
        
        balances[_to] = balances[_to].add(_value);
        tokenIssuedMkt = tokenIssuedMkt.add(_value);
        totalSupply = totalSupply.add(_value);
        personalLock[_to] = true;
        
        Transfer(0x0, _to, _value);
    }
    
    function withdrawDevTokens(address _to, uint _value) public onlyOwner // ȸ�� ���� ��ū ���
    {
        require(devSupply > tokenIssuedDevelop); // ȸ�簡 ������ �ִ� ��ū�� ������ ����� ��ū�� �������� ���ƾ� ��
        require(devSupply > tokenIssuedDevelop.add(_value));
        
        balances[_to] = balances[_to].add(_value); // ���濡�� ��ū�� ������
        tokenIssuedMkt = tokenIssuedMkt.add(_value); // ȸ�簡 �Ǹ��� ��ū�� ���� ����
        totalSupply = totalSupply.add(_value); 
        personalLock[_to] = true;
        
        Transfer(0x0, _to, _value);
    }
    
    function isIcoFinshed() public constant returns (bool)
    {
        uint nowTime = atNow();
        
        if(crowdSaleSecondEndDate < nowTime)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    function checkLeftToken() public returns (uint)
    {
        require(isIcoFinshed() == true);
        saleTokenLeft = saleSupply.sub(tokenIssuedSale);
        return saleTokenLeft;
        
    }
    
    function airdrop(address[] _to, uint[] value) public onlyOwner 
    {
        uint valueSum=0;

        for(uint i=0; i<= value.length; i++){
            valueSum +=  value[i];
        }

        require(saleSupply >= valueSum);

        for(uint j=0; j<= _to.length; j++) {
            transfer(_to[j], value[j]);
            Transfer(owner,_to[j], value[j]);
        }
    }

    function burnleftToken() public returns (bool _success)
    {
        require(isIcoFinshed() == true);
        
        burnRatio = 100 - (saleSupply - saleTokenLeft).div(saleSupply); 
        
        mktSupply = mktSupply.mul(burnRatio);
        devSupply = devSupply.mul(burnRatio);
        saleSupply = saleSupply.mul(burnRatio);
        
        BurnToken(saleSupply, devSupply, mktSupply);

        return true;
    }

}