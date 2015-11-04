import 'dapple/test.sol';
import 'asset/asset0.sol';
import 'auth/auth_test.sol';

contract helper {
    function do_transfer( DSAsset0 a, address to, uint amount ) returns (bool) {
        return a.transfer(to, amount);
    }
}

contract DSAsset0Test is Test {
    DSAsset0 A;
    helper h;
    address bob;
    function setUp() {
        h = new helper();
        bob = address(0x1);
	var _db = new DSBalanceDB();
	_db.add_balance( me , 1000 );
        A = new DSAsset0Impl( _db );
        var (bal, ok) = A.get_balance(me);
        assertTrue( ok );
        assertTrue( bal == uint(1000) );
    }
    function testOnlyOwnerCanTransfer() {
        this.assertFalse( h.do_transfer(A, address(h), 100) );
        var (bal, ok) = A.get_balance(address(h));
        assertEq( bal, 0 );
    }
    function testSwapDB() {
	var old_db = DSAsset0Impl(A).db();
        var new_db = new DSBalanceDB();
	new_db._ds_update_authority( address(A) );
	A.swap_db( new_db, DSAuthority(this) );
	old_db.add_balance( me, 500 );
	var (bal, ok) = old_db.get_balance( me );
	assertTrue(bal==1500, "didn't gain authority of old db");
    }

}
