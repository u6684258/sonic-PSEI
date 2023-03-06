// Modified from https://github.com/appliedzkp/semaphore/blob/master/contracts/sol/verifier.sol
// SPDX-License-Identifier: MIT

// please notice that current code may be temporary code for cost estimation, and right version is annotated

pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;
import "./Pairing.sol";
// import "./PolyCoeff.sol";
import { Constants } from "./Constants.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

contract Verifier is Constants {

    using Pairing for *;

    event verifyResult(bool result);

    // d_j when j=1
    uint256 d = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
    uint256 yz = mulmod(y, z, BABYJUB_P);
    uint256 z = uint256(21284924740537517593391635090683107806948436131904811688892120057033464016678);
    uint256 y = uint256(21356640755055926883299664242251323519715676831624930462071588778907420237277);
    uint256 beta = uint256(21300179784197405894513072539865320928097398620497813074953097024203243212233);

    // number of constraints?
    uint256 N = 21;
    uint256 z_n = expMod(z, N, BABYJUB_P);

    struct UserCommitments{

        // ECDSA signature
        bytes32 message;
        bytes sig;
        address addr;

        // d_j when j=1

        // S

        // gamma(z) = gamma[0] + gamma[1]*z + gamma[2]*z^2 + ...
        uint256[1] gamma1;
        uint256[1] gamma2;
        uint256[2] gamma3;
        uint256[1] gamma4;
        uint256[1] gamma5;
        uint256[2] gamma6;
        uint256[1] gamma7;
        // the committed prove, g^p[x], g^w[x]
        Pairing.G1Point pi_1;
        Pairing.G1Point pi_2;


        // other prover submitted variables
        uint256 r_1;
        uint256 r_tilde;
        uint256 t;
        uint256 k;
        uint256 s_tilde;
        uint256 r_2;
        uint256 s_1_tilde;
        uint256 s_2_tilde;

        // poly commitments, Fs
        Pairing.G1Point D;
        Pairing.G1Point R_tilde;
        Pairing.G1Point R;
        Pairing.G1Point T;
        Pairing.G1Point K;
        Pairing.G1Point S_x;
        Pairing.G1Point S_y;
    }
    // too many local variables, so create a struct
    struct verification_variables{
        // Z(T / Si)[z] * β^(i-1)
        uint256 Z_beta_1; // i = 1,  etc.
        uint256 Z_beta_2;
        uint256 Z_beta_3;
        uint256 Z_beta_4;
        // uint256 Z_beta_5;
        // uint256 Z_beta_6;
        // uint256 Z_beta_7;

        // H calculation
        // Pairing.G1Point H;

        // R calculation, denoted RR because already have a R for one Fcommitment
        // first calculate the PI product, and to do this first calculate the power of g after product to reduce gas cost
        // calculate the PI product
        // Pairing.G1Point RR;

        // check the equation, then check others
        // bool result;
    }

    // Sonic proofs
    // D_j when j=1
    // Pairing.G1Point pi_D = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_R_tilde = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_R1 = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_R2 = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_T = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_K = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_S_x1 = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_S_x2 = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point pi_S_y = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // uint256 r_1 = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
    // uint256 r_tilde = uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225);
    // uint256 t = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
    // uint256 k = uint256(11598511819595573397693757683043215863237090817957830497519701049476846220233);
    // uint256 s_tilde = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
    // uint256 r_2 = uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225);
    // uint256 s_1_tilde = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
    // uint256 s_2_tilde = uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225);
    // // poly commitments, Fs
    // Pairing.G1Point D = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point R_tilde = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point R = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point T = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point K = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point S_x = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // Pairing.G1Point S_y = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
    // bytes32 message = ethMessageHash("20900429899291009073299289469660149716785596251491300692035681492016939179257, 433691023568696153828599652727177493671905883454953868604074871528381220097");
    // bytes sig = hex"19ec5dc5aa05a220cd210a113352596ebf80d06a6f776b8e0c656e50a5c5567f1e8a7f23fb27f77ea5b5d42f0e2384facdebebd85f026e2a73e94d4690a40a6801";
    // address addr = 0xE448992FdEaF94784bBD8f432d781C061D907985;

    // formerly used variables:

    // temporarily this is for original sonic
    // uint256[21] Proof = [
    //     uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
    //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225),
    //     uint256(20900429899291009073299289469660149716785596251491300692035681492016939179257),
    //     uint256(17015433841169487450406840425175642150965883946544965612916879717959251917877),
    //     uint256(433691023568696153828599652727177493671905883454953868604074871528381220097),
    //     uint256(10320531664273889342578906132837836076031009559738199149165995480549188738219),
    //     uint256(5841514956038981489672186264970094693930045609713312309929445225955171101947),
    //     uint256(5021024840007099401420413415719005463562614305701472747429400657816854795888),
    //     uint256(20774065911754029615648528083815650325450840922528127398846513310899898519818),
    //     uint256(15033194806153309440324576121312701377491848712637707126378339071163915088607),
    //     uint256(13797601081368067296147105517336555699959400728196376360418452678919689273357),
    //     uint256(347536244405038501480645670232637364896709701574004323632284243300674648233),
    //     uint256(14150985670258525975582637074878024272235049272474457475329855381177734047698),
    //     uint256(2655786006985334435742353147654701867454007390061009682990360208958229883457),
    //     uint256(19749978915220999581635876327451130211831443864540429941950424972239040718725),
    //     uint256(18652734379260577017619098828238354228621932558467343220803598526754221068969),
    //     uint256(19231643171984527412379363884712632725022106910875011856721870145973184299950),
    //     uint256(11890584382703984881384687349129438589403848436060509080598302278432395889958),
    //     uint256(19848703903105846067635106277601755727734486581037082434405934553883502968806),
    //     uint256(7073067203970200196273245091229017314841577127190841947842173598530677375580),
    //     uint256(11142795172845103846997117758219330284910812886430955732663385421662518242916)
    // ];

    // length of longest u,v,w, i.e. longest length of a,b,c, linear to poly. current 32: 2994

    // SOCC_hscS = [G1Point S_j, uint256 s_j, G1Point W_j]
    // uint256[5] SOCC_hscS = [
    //     uint256(4856595452220518861283513887787149560249872199754148373623768058895650888886),
    //     uint256(18903793806709064235976701805982270837399009185115750427816521247566249210556),
    //     uint256(11142795172845103846997117758219330284910812886430955732663385421662518242916),
    //     uint256(21371202341828297453905088304285070177929072675831707150146249345026206448204),
    //     uint256(2804295765584777874267821186909392907007222244895837511075392229436674961086)
    // ];
    // SOCC_hscW = [uint256 s'_j,G1Point W'_j, G1Point Q_j]
    // uint256[5] SOCC_hscW = [
    //     uint256(10516069979663785554384039720791935537971662430097624533692998141893610132813),
    //     uint256(4047408704098476939730481302397316844045052246660100325786631118072453155095),
    //     uint256(3536770324764440576997419732517461268782698510962602892817204324264966117745),
    //     uint256(14245367996788138561788347307320292816184394224142842975302936827932398609764),
    //     uint256(4809015920432886449944012129537258787815219963382067822305826740230093200527)
    // ];

    // Pairing.G1Point hscQv = Pairing.G1Point(
    //     uint256(2990558601454446836641627272921201963123578559834602407524792456795005493261),
    //     uint256(13202662347545347168000079135411531495309137838398006144762638337293564502641)
    // );
    // Pairing.G1Point hscC = Pairing.G1Point(
    //     uint256(20354021681082976488982424663336191185782081465046767166624106617637273115698),
    //     uint256(7434894914590215425794637416957100516507193983165584369402225555559623348194)
    // );

    // uint256 u = uint256(8197071660809916300712359474937866146139983659726903111927633346212682272753);
    // uint256 v = uint256(18304223670379022123371455395869338667757056554451611927086438308637909615067);

    // from terminal
    // uint256 s_uv = uint256(7791702837224372263152657165191932519240106980588006270334507770946892728366);

    // The G2 generator
    // why it's here? because the G2Gen() doesn't work in verify() for unknown reason
    // Pairing.G2Point g2Generator = Pairing.G2Point({
    //     X: [ SRS_G2_X_0[0], SRS_G2_X_1[0] ],
    //     Y: [ SRS_G2_Y_0[0], SRS_G2_Y_1[0] ]
    // });
    // g
    // Pairing.G1Point g = Pairing.G1Point(1, 2);
    
    // h^α
    // Pairing.G2Point SRS_G2_2 = Pairing.G2Point({
    //     X: [ SRS_G2_X_0_Pos[2], SRS_G2_X_1_Pos[2] ],
    //     Y: [ SRS_G2_Y_0_Pos[2], SRS_G2_Y_1_Pos[2] ]
    // });

    // // Sonic version - Verify a single-point evaluation of a polynominal
    // function verify(
    //     Pairing.G1Point memory _commitment, // F
    //     Pairing.G1Point memory _proof, // W
    //     uint256 _index,  // z
    //     uint256 _value  // F(z) or v
    //     // uint proofIndex,
    //     // bool isT
    // ) public view returns (bool) {
    //     // Make sure each parameter is less than the prime q
    //     require(_commitment.X < BABYJUB_P, "Verifier.verifyKZG: _commitment.X is out of range");
    //     require(_commitment.Y < BABYJUB_P, "Verifier.verifyKZG: _commitment.Y is out of range");
    //     require(_proof.X < BABYJUB_P, "Verifier.verifyKZG: _proof.X is out of range");
    //     require(_proof.Y < BABYJUB_P, "Verifier.verifyKZG: _proof.Y is out of range");
    //     require(_index < BABYJUB_P, "Verifier.verifyKZG: _index is out of range");
    //     require(_value < BABYJUB_P, "Verifier.verifyKZG: _value is out of range");
       
    //     Pairing.G1Point memory negProof = Pairing.negate(Pairing.mulScalar(_proof, _index));
    //     Pairing.G1Point memory mulProof = Pairing.plus(Pairing.mulScalar(G1Gen(), _value), negProof);

    //     return Pairing.pairing_3point(_proof, SRS_G2_hAlphaX1,
    //                             mulProof, SRS_G2_hAlphaX0,
    //                             _commitment, t_hxdmax);
    // }



    /*
     * Verifies a single-point evaluation of a polynominal using the KZG
     * commitment scheme.
     *    - p(X) is a polynominal
     *    - _value = p(_index) 
     *    - commitment = commit(p)
     *    - proof = genProof(p, _index, _value)
     * Returns true if and only if the following holds, and returns false
     * otherwise:
     *     e(commitment - commit([_value]), G2.g) == e(proof, commit([0, 1]) - zCommit)
     * @param _commitment The KZG polynominal commitment.
     * @param _proof The proof.
     * @param _index The x-value at which to evaluate the polynominal.
     * @param _value The result of the polynominal evaluation.
     */
    //   - Verify a single-point evaluation of a polynominal

    // function verify(
    //     Pairing.G1Point memory _commitment, // F
    //     Pairing.G1Point memory _proof, // π
    //     uint256 _index,  // z
    //     uint256 _value  // F(z) or v
    //     //uint proofIndex
    // ) public view returns (bool) {
    //     // Make sure each parameter is less than the prime q
    //     require(_commitment.X < BABYJUB_P, "Verifier.verifyKZG: _commitment.X is out of range");
    //     require(_commitment.Y < BABYJUB_P, "Verifier.verifyKZG: _commitment.Y is out of range");
    //     require(_proof.X < BABYJUB_P, "Verifier.verifyKZG: _proof.X is out of range");
    //     require(_proof.Y < BABYJUB_P, "Verifier.verifyKZG: _proof.Y is out of range");
    //     require(_index < BABYJUB_P, "Verifier.verifyKZG: _index is out of range");
    //     require(_value < BABYJUB_P, "Verifier.verifyKZG: _value is out of range");
    //     // Check that 
    //     //     e(commitment - aCommit, G2.g) == e(proof, xCommit - zCommit)
    //     //     e(commitment - aCommit, G2.g) / e(proof, xCommit - zCommit) == 1
    //     //     e(commitment - aCommit, G2.g) * e(proof, xCommit - zCommit) ^ -1 == 1
    //     //     e(commitment - aCommit, G2.g) * e(-proof, xCommit - zCommit) == 1
    //     // where:
    //     //     aCommit = commit([_value]) = SRS_G1_0 * _value
    //     //     xCommit = commit([0, 1]) = SRS_G2_1
    //     //     zCommit = commit([_index]) = SRS_G2_1 * _index

    //     // To avoid having to perform an expensive operation in G2 to compute
    //     // xCommit - zCommit, we instead check the equivalent equation:
    //     //     e(commitment - aCommit, G2.g) * e(-proof, xCommit) * e(-proof, -zCommit) == 1
    //     //     e(commitment - aCommit, G2.g) * e(-proof, xCommit) * e(proof, zCommit) == 1
    //     //     e(commitment - aCommit, G2.g) * e(-proof, xCommit) * e(index * proof, G2.g) == 1
    //     //     e((index * proof) + (commitment - aCommit), G2.g) * e(-proof, xCommit) == 1

    //     // Compute commitment - aCommitment
    //     Pairing.G1Point memory commitmentMinusA = Pairing.plus(
    //         _commitment,
    //         Pairing.negate(
    //             Pairing.mulScalar(Pairing.G1Point(1, 2), _value)
    //         )
    //     );

    //     // Negate the proof
    //     Pairing.G1Point memory negProof = Pairing.negate(_proof);

    //     // Compute index * proof
    //     Pairing.G1Point memory indexMulProof = Pairing.mulScalar(_proof, _index);

    //     // Return true if and only if
    //     // e((index * proof) + (commitment - aCommitment), G2.g) * e(-proof, xCommit) == 1
    //     return Pairing.pairing(
    //         Pairing.plus(indexMulProof, commitmentMinusA),
    //         g2Generator,
    //         negProof,
    //         SRS_G2_1 // it's h. original author of kzg commitment code call it 'xCommit' here
    //     );
    // }

    // modified sonic verifier using KZG commitment

    // function verifySonic_KZG(
    //     // uint256[21] memory Proof,
    //     // uint256[2] memory Randoms
    // ) public returns (bool) {

    //     // simulate calculating kY
    //     // uint256 ky = evalKPoly();
    //     // // // simulate calculating sXY
    //     // uint256 sx = evalXPoly();
    //     // uint256 sy = evalXPoly();

    //     //uint256 yz = mulmod(y, z, BABYJUB_P);

    //     // y^N for halo implementation style
    //     // uint256 y_n = expMod(z, N, BABYJUB_P);
    //     // t for halo implementation style
    //     // uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], BABYJUB_P), 
    //     //                           addmod(addmod(Proof[12], 
    //     //                                         Proof[15], BABYJUB_P), 
    //     //                                  evalS, BABYJUB_P), BABYJUB_P),
    //     //                     mulmod((BABYJUB_P - evalK), y_n, BABYJUB_P),
    //     //                     BABYJUB_P);

    //     uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], BABYJUB_P), 
    //                               addmod(addmod(Proof[12], 
    //                                             Proof[15], BABYJUB_P), 
    //                                      evalS, BABYJUB_P), BABYJUB_P),
    //                         (BABYJUB_P - evalK), BABYJUB_P);


    //     bool verifySignature = recover(message, sig) == addr;
    //     // bool result = verify(Pairing.G1Point(Proof[0], Proof[1]), // aLocal
    //     //               Pairing.G1Point(Proof[7], Proof[8]),
    //     //               z, 
    //     //               Proof[6]) &&
    //     //         verify(Pairing.G1Point(Proof[0], Proof[1]), // bLocal
    //     //               Pairing.G1Point(Proof[13], Proof[14]),
    //     //               yz,
    //     //               Proof[12]) &&
    //     //         verify(Pairing.G1Point(Proof[2], Proof[3]), // aRaw
    //     //               Pairing.G1Point(Proof[10], Proof[11]),
    //     //               z,
    //     //               Proof[9]) &&
    //     //         verify(Pairing.G1Point(Proof[2], Proof[3]), // bRaw
    //     //               Pairing.G1Point(Proof[16], Proof[17]),
    //     //               yz,
    //     //               Proof[15]) &&
    //     //         verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                               
    //     //         verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                                            // pcV srsLocal (srsD srsLocal) commitK y (k, wk)
    //     //         verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                                            // pcV srsLocal (srsD srsLocal) commitC y (c, wc)
    //     //         verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                                            // pcV srsLocal (srsD srsLocal) commitC yOld (cOld, wcOld)
    //     //         verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                                            //, pcV srsLocal (srsD srsLocal) commitC yNew (cNew, wcNew)
    //     //         verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                                            //, pcV srsLocal (srsD srsLocal) commitS z (s, ws)
    //     //         verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                                            //, pcV srsLocal (srsD srsLocal) commitSOld z (sOld, wsOld)
    //     //          verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //     //               Pairing.G1Point(Proof[18], Proof[19]),
    //     //               z,
    //     //               t) &&                                           //, pcV srsLocal (srsD srsLocal) commitSNew z (sNew, wsNew)
    //     //         verifySignature &&
    //     //         Proof[6] == Proof[7] && // c_old == s_old
    //     //         Proof[8] == Proof[9] && // c_new == s_new
    //     //         Proof[10] == Proof[11]; // c == s

    //     // temporary code for estimating gas cost, the above is correct version
    //     bool result = verify(Pairing.G1Point(Proof[0], Proof[1]), // aLocal
    //                   Pairing.G1Point(Proof[7], Proof[8]),
    //                   z, 
    //                   Proof[6]);
    //     result = verify(Pairing.G1Point(Proof[0], Proof[1]), // bLocal
    //                   Pairing.G1Point(Proof[13], Proof[14]),
    //                   yz,
    //                   Proof[12]);
    //     result = verify(Pairing.G1Point(Proof[2], Proof[3]), // aRaw
    //                   Pairing.G1Point(Proof[10], Proof[11]),
    //                   z,
    //                   Proof[9]);
    //     result = verify(Pairing.G1Point(Proof[2], Proof[3]), // bRaw
    //                   Pairing.G1Point(Proof[16], Proof[17]),
    //                   yz,
    //                   Proof[15]);
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                              
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                                            // pcV srsLocal (srsD srsLocal) commitK y (k, wk)
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                                            // pcV srsLocal (srsD srsLocal) commitC y (c, wc)
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                                            // pcV srsLocal (srsD srsLocal) commitC yOld (cOld, wcOld)
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                                            //, pcV srsLocal (srsD srsLocal) commitC yNew (cNew, wcNew)
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                                            //, pcV srsLocal (srsD srsLocal) commitS z (s, ws)
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                                            //, pcV srsLocal (srsD srsLocal) commitSOld z (sOld, wsOld)
    //     result = verify(Pairing.G1Point(Proof[4], Proof[5]), // t
    //                   Pairing.G1Point(Proof[18], Proof[19]),
    //                   z,
    //                   t);                                           //, pcV srsLocal (srsD srsLocal) commitSNew z (sNew, wsNew)
    //     result = verifySignature;
    //     result = Proof[6] == Proof[7]; // c_old == s_old
    //     result = Proof[8] == Proof[9]; // c_new == s_new
    //     result = Proof[10] == Proof[11]; // c == s
    //     emit verifyResult(result);
    //     return result;
    // }

    // sonic verifier

    // function verifySonic(
    //     // uint256[21] memory Proof,
    //     // uint256[2] memory Randoms
    // ) public returns (bool) {

    //     // simulate calculating kY
    //     // uint256 ky = evalKPoly();
    //     // // // simulate calculating sXY
    //     // uint256 sx = evalXPoly();
    //     // uint256 sy = evalXPoly();

    //     // uint256 yz = mulmod(y, z, BABYJUB_P);

    //     // y^N for halo implementation style
    //     // uint256 y_n = expMod(z, N, BABYJUB_P);
    //     // t for halo implementation style
    //     // uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], BABYJUB_P), 
    //     //                           addmod(addmod(Proof[12], 
    //     //                                         Proof[15], BABYJUB_P), 
    //     //                                  evalS, BABYJUB_P), BABYJUB_P),
    //     //                     mulmod((BABYJUB_P - evalK), y_n, BABYJUB_P),
    //     //                     BABYJUB_P);



    //     // bool result = verify(D,
    //     //               pi_D,
    //     //               z, 
    //     //               d);
    //     //     && verify(R_tilde,
    //     //               pi_R_tilde,
    //     //               z,
    //     //               r_tilde);
    //     //     && verify(R,
    //     //               pi_R1,
    //     //               z,
    //     //               r_1);
    //     //     && verify(R,
    //     //               pi_R2,
    //     //               yz,
    //     //               r_2);
    //     //     && verify(T,
    //     //               pi_T,
    //     //               z,
    //     //               t);
    //     //     && verify(K,
    //     //               pi_K,
    //     //               y,
    //     //               k);
    //     //     && verify(S_x,
    //     //               pi_S_x1,
    //     //               z,
    //     //               s_tilde);
    //     //     && verify(S_x,
    //     //               pi_S_x2,
    //     //               1,
    //     //               s_1_tilde);
    //     //     && verify(S_y,
    //     //               pi_S_y,
    //     //               y,
    //     //               s_2_tilde);
    //     //     && recover(message, sig) == addr; //verifySignature
    //     //     && r_1 == addmod(r_tilde, mulmod(d, z_n, BABYJUB_P), BABYJUB_P);
    //     //     && t == addmod(mulmod(r_1, 
    //     //                           addmod(r_2,
    //     //                                  s_tilde, BABYJUB_P), BABYJUB_P),
    //     //                     (BABYJUB_P - k), BABYJUB_P);
    //     //     && s_1_tilde == s_2_tilde;

    //     // temporary code for estimating gas cost, the above is correct version
    //     bool result = verify(D,
    //                   pi_D,
    //                   z, 
    //                   d);
    //     result = verify(R_tilde,
    //                   pi_R_tilde,
    //                   z,
    //                   r_tilde);
    //     result = verify(R,
    //                   pi_R1,
    //                   z,
    //                   r_1);
    //     result = verify(R,
    //                   pi_R2,
    //                   yz,
    //                   r_2);
    //     result = verify(T,
    //                   pi_T,
    //                   z,
    //                   t);
    //     result = verify(K,
    //                   pi_K,
    //                   y,
    //                   k);
    //     result = verify(S_x,
    //                   pi_S_x1,
    //                   z,
    //                   s_tilde);
    //     result = verify(S_x,
    //                   pi_S_x2,
    //                   1,
    //                   s_1_tilde);
    //     result = verify(S_y,
    //                   pi_S_y,
    //                   y,
    //                   s_2_tilde);
    //     result = recover(message, sig) == addr; //verifySignature
    //     result = r_1 == addmod(r_tilde, mulmod(d, z_n, BABYJUB_P), BABYJUB_P);
    //     result = t == addmod(mulmod(r_1, 
    //                               addmod(r_2,
    //                                      s_tilde, BABYJUB_P), BABYJUB_P),
    //                         (BABYJUB_P - k), BABYJUB_P);
    //     result = s_1_tilde == s_2_tilde;

    //     emit verifyResult(result);
    //     return result;
    // }

    // add improvement for batched commitments of original KZG
    /*
    we check e<g^w[α],h^α> e<(g^w[α])^-z,h> == RHS
     */
    // function verifySonicBatchedOriginKZG(
    //     // uint256[21] memory Proof,
    //     // uint256[2] memory Randoms
    // ) public returns (bool) {

    //     // simulate calculating kY
    //     // uint256 ky = evalKPoly();
    //     // // // simulate calculating sXY
    //     // uint256 sx = evalXPoly();
    //     // uint256 sy = evalXPoly();

        
    //     // y^N for halo implementation style
    //     // uint256 y_n = expMod(z, N, BABYJUB_P);

    //     // t for halo implementation style
    //     // uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], BABYJUB_P), 
    //     //                           addmod(addmod(Proof[12], 
    //     //                                         Proof[15], BABYJUB_P), 
    //     //                                  evalS, BABYJUB_P), BABYJUB_P),
    //     //                     mulmod((BABYJUB_P - evalK), y_n, BABYJUB_P),
    //     //                     BABYJUB_P);

    //     // uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], BABYJUB_P), 
    //     //                           addmod(addmod(Proof[12], 
    //     //                                         Proof[15], BABYJUB_P), 
    //     //                                  evalS, BABYJUB_P), BABYJUB_P),
    //     //                     (BABYJUB_P - evalK), BABYJUB_P);


    //     bool verifySignature = recover(message, sig) == addr;

    //     // F
    //     Pairing.G1Point[8] memory F = [
    //                                 Pairing.G1Point(Proof[0], Proof[1]),//R0
    //                                 Pairing.G1Point(Proof[2], Proof[3]), // Rj
    //                                 Pairing.G1Point(Proof[4], Proof[5]), //T
    //                                 Pairing.G1Point(Proof[6], Proof[7]), //C
    //                                 Pairing.G1Point(Proof[8], Proof[9]), //Ck
    //                                 Pairing.G1Point(Proof[10], Proof[11]), //S
    //                                 Pairing.G1Point(Proof[12], Proof[13]), //Sold
    //                                 Pairing.G1Point(Proof[14], Proof[15])  //Snew
    //                                 ];
    //     // Z(T / Si)[z] * β^(i-1)
    //     uint256 Z_beta_1 = 1; // i = 1,  etc.
    //     uint256 Z_beta_2 = beta;
    //     uint256 Z_beta_3 = mulmod(Z_beta_2, beta, BABYJUB_P);
    //     uint256 Z_beta_4 = mulmod(Z_beta_3, beta, BABYJUB_P);
    //     uint256 Z_beta_5 = mulmod(Z_beta_4, beta, BABYJUB_P);
    //     uint256 Z_beta_6 = mulmod(Z_beta_5, beta, BABYJUB_P);
    //     uint256 Z_beta_7 = mulmod(Z_beta_6, beta, BABYJUB_P);
    //     uint256 Z_beta_8 = mulmod(Z_beta_7, beta, BABYJUB_P);

    //     Z_beta_1 = mulmod(Z_beta_1, z_calculation(1), BABYJUB_P);
    //     Z_beta_2 = mulmod(Z_beta_2, z_calculation(2), BABYJUB_P);
    //     Z_beta_3 = mulmod(Z_beta_3, z_calculation(3), BABYJUB_P);
    //     Z_beta_4 = mulmod(Z_beta_4, z_calculation(4), BABYJUB_P);
    //     Z_beta_5 = mulmod(Z_beta_5, z_calculation(5), BABYJUB_P);
    //     Z_beta_6 = mulmod(Z_beta_6, z_calculation(6), BABYJUB_P);
    //     Z_beta_7 = mulmod(Z_beta_7, z_calculation(7), BABYJUB_P);
    //     Z_beta_8 = mulmod(Z_beta_8, z_calculation(8), BABYJUB_P);

    //     // the prove, g^p[α], g^w[α]
    //     Pairing.G1Point[2] memory pi = [
    //         Pairing.G1Point(1, 2),
    //         Pairing.G1Point(1, 2)
    //     ];
    //     // product_result is the first G1 element of the RHS pairing
    //     // first calculate the uppercase Pi product
    //     Pairing.G1Point memory product_result = Pairing.mulScalar(Pairing.plus(D, 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             addmod(gamma1[0], 
    //                                                                             mulmod(gamma1[1], z, BABYJUB_P), 
    //                                                                             BABYJUB_P)))), Z_beta_1);
    //     product_result = Pairing.plus(product_result, 
    //                                 Pairing.mulScalar(Pairing.plus(R_tilde, 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             addmod(gamma2[0], 
    //                                                                             mulmod(gamma2[1], z, BABYJUB_P), 
    //                                                                             BABYJUB_P)))), Z_beta_2));
    //     product_result = Pairing.plus(product_result, 
    //                                 Pairing.mulScalar(Pairing.plus(R, 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             gamma3[0]))), Z_beta_3));
    //     product_result = Pairing.plus(product_result, 
    //                                 Pairing.mulScalar(Pairing.plus(T, 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             addmod(addmod(gamma4[0], 
    //                                                                             mulmod(gamma4[1], z, BABYJUB_P), 
    //                                                                             BABYJUB_P),
    //                                                                             mulmod(gamma4[2], 
    //                                                                             mulmod(z, z, 
    //                                                                             BABYJUB_P), 
    //                                                                             BABYJUB_P),
    //                                                                             BABYJUB_P)
    //                                                                             )))
    //                                                     , Z_beta_4)
    //                                     );
    //     product_result = Pairing.plus(product_result, 
    //                                 Pairing.mulScalar(Pairing.plus(K, 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             gamma5[0]))), Z_beta_5));
    //     product_result = Pairing.plus(product_result, 
    //                                 Pairing.mulScalar(Pairing.plus(S_x, 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             gamma6[0]))), Z_beta_6));
    //     product_result = Pairing.plus(product_result, 
    //                                 Pairing.mulScalar(Pairing.plus(S_y, 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             gamma7[0]))), Z_beta_7));
    //     product_result = Pairing.plus(product_result, 
    //                                 Pairing.mulScalar(Pairing.plus(F[7], 
    //                                                             Pairing.negate(Pairing.mulScalar(g, 
    //                                                                             gamma8[0]))), Z_beta_8));
    //     // then add the first item before the uppercase Pi product
    //     product_result = Pairing.plus(product_result,
    //                                 Pairing.negate(Pairing.plus(pi[0],
    //                                                 Pairing.mulScalar(g,
    //                                                                 z_calculation(9)))));//zT[z]

    //     // check e<g^w[α],h^α>e<g^w[α]g^-z,h> == RHS, then check others
    //     // bool result = Pairing.pairing_3point(
    //     //     pi[1],
    //     //     SRS_G2_2, // h^α, see above
    //     //     Pairing.negate(Pairing.mulScalar(pi[1], z)),
    //     //     SRS_G2_1, // h, see above
    //     //     Pairing.negate(product_result),
    //     //     SRS_G2_1
    //     //     )
    //     //     && verifySignature
    //     //     && Proof[6] == Proof[7] // c_old == s_old
    //     //     && Proof[8] == Proof[9] // c_new == s_new
    //     //     && Proof[10] == Proof[11]; // c == s

    //     // temporary code for estimating gas cost, the above is correct version
    //     // check e<g^w[α],h^α>e<(g^w[α])^-z,h> == RHS, then check others
    //     bool result = Pairing.pairing_3point(
    //         pi[1], // g^w[α]
    //         SRS_G2_2, // h^α, see above
    //         Pairing.negate(Pairing.mulScalar(pi[1], z)),
    //         SRS_G2_1, // h, see above
    //         Pairing.negate(product_result),
    //         SRS_G2_1
    //         );
    //     result = verifySignature;
    //     result = Proof[6] == Proof[7]; // c_old == s_old
    //     result = Proof[8] == Proof[9]; // c_new == s_new
    //     result = Proof[10] == Proof[11]; // c == s
    //     emit verifyResult(result);
    //     return result;
    // }


    // using batched commitments of sonic version of modified KZG
    // used for test convenience only
    function verifySonicBatched(
    ) public{
        
        // for reference:
        
        // // ECDSA signature
        // bytes32 message = ethMessageHash("20900429899291009073299289469660149716785596251491300692035681492016939179257, 433691023568696153828599652727177493671905883454953868604074871528381220097");
        // bytes sig = hex"19ec5dc5aa05a220cd210a113352596ebf80d06a6f776b8e0c656e50a5c5567f1e8a7f23fb27f77ea5b5d42f0e2384facdebebd85f026e2a73e94d4690a40a6801";
        // address addr = 0xE448992FdEaF94784bBD8f432d781C061D907985;

        // // d_j when j=1
        // uint256 d = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
        // uint256 yz = mulmod(y, z, BABYJUB_P);
        // uint256 z = uint256(21284924740537517593391635090683107806948436131904811688892120057033464016678);
        // uint256 y = uint256(21356640755055926883299664242251323519715676831624930462071588778907420237277);
        // uint256 beta = uint256(21300179784197405894513072539865320928097398620497813074953097024203243212233);
        // // S
        // uint256[1] S1 = [z];
        // uint256[1] S2 = [z];
        // uint256[2] S3 = [z, yz];
        // uint256[1] S4 = [z];
        // uint256[1] S5 = [y];
        // uint256[2] S6 = [z, 1];
        // uint256[1] S7 = [y];
        // // gamma(z) = gamma[0] + gamma[1]*z + gamma[2]*z^2 + ...
        // uint256[1] gamma1 = [z];
        // uint256[1] gamma2 = [z];
        // uint256[2] gamma3 = [z, yz];
        // uint256[1] gamma4 = [z];
        // uint256[1] gamma5 = [z];
        // uint256[2] gamma6 = [z, 1];
        // uint256[1] gamma7 = [z];
        // // the committed prove, g^p[x], g^w[x]
        // Pairing.G1Point pi_1 = Pairing.G1Point(1, 2);
        // Pairing.G1Point pi_2 = Pairing.G1Point(1, 2);

        // // number of constraints?
        // uint256 N = 21;
        // uint256 z_n = expMod(z, N, BABYJUB_P);

        // // other prover submitted variables
        // uint256 r_1 = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
        // uint256 r_tilde = uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225);
        // uint256 t = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
        // uint256 k = uint256(11598511819595573397693757683043215863237090817957830497519701049476846220233);
        // uint256 s_tilde = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
        // uint256 r_2 = uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225);
        // uint256 s_1_tilde = uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986);
        // uint256 s_2_tilde = uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225);

        // // poly commitments, Fs
        // Pairing.G1Point D = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
        //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
        // Pairing.G1Point R_tilde = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
        //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
        // Pairing.G1Point R = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
        //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
        // Pairing.G1Point T = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
        //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
        // Pairing.G1Point K = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
        //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
        // Pairing.G1Point S_x = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
        //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));
        // Pairing.G1Point S_y = Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
        //     uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225));

        verifySonicBatchedImpl(UserCommitments(

            // ECDSA signature
            ethMessageHash("20900429899291009073299289469660149716785596251491300692035681492016939179257, 433691023568696153828599652727177493671905883454953868604074871528381220097"),
            hex"19ec5dc5aa05a220cd210a113352596ebf80d06a6f776b8e0c656e50a5c5567f1e8a7f23fb27f77ea5b5d42f0e2384facdebebd85f026e2a73e94d4690a40a6801",
            0xE448992FdEaF94784bBD8f432d781C061D907985,

            // d_j when j=1


            // gamma(z) = gamma[0] + gamma[1]*z + gamma[2]*z^2 + ...
            [z],
            [z],
            [z, yz],
            [z],
            [z],
            [z, 1],
            [z],
            // the committed prove, g^p[x], g^w[x]
            Pairing.G1Point(1, 2),
            Pairing.G1Point(1, 2),


            // other prover submitted variables
            uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
            uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225),
            uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
            uint256(11598511819595573397693757683043215863237090817957830497519701049476846220233),
            uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
            uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225),
            uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
            uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225),

            // poly commitments, Fs
            Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
                uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225)),
            Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
                uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225)),
            Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
                uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225)),
            Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
                uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225)),
            Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
                uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225)),
            Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
                uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225)),
            Pairing.G1Point(uint256(20435686948508171234472206488737953800505595616105823290561271581793730135986),
                uint256(7613038940582986439878577004424311309737615170791456916446723479068371769225))
        ));
    }

    function verifySonicBatchedImpl(
        UserCommitments memory cm
    ) public returns (bool) {

        // simulate calculating kY
        // uint256 ky = evalKPoly();
        // // // simulate calculating sXY
        // uint256 sx = evalXPoly();
        // uint256 sy = evalXPoly();

        
        // y^N for halo implementation style
        // uint256 y_n = expMod(z, N, BABYJUB_P);

        // t for halo implementation style
        // uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], BABYJUB_P), 
        //                           addmod(addmod(Proof[12], 
        //                                         Proof[15], BABYJUB_P), 
        //                                  evalS, BABYJUB_P), BABYJUB_P),
        //                     mulmod((BABYJUB_P - evalK), y_n, BABYJUB_P),
        //                     BABYJUB_P);

        // uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], BABYJUB_P), 
        //                           addmod(addmod(Proof[12], 
        //                                         Proof[15], BABYJUB_P), 
        //                                  evalS, BABYJUB_P), BABYJUB_P),
        //                     (BABYJUB_P - evalK), BABYJUB_P);
        verification_variables memory vars;
        // Z(T / Si)[z] * β^(i-1)
        vars.Z_beta_1 = mulmod(1, z_calculation(1), BABYJUB_P); // i = 1,  etc.
        vars.Z_beta_2 = mulmod(beta, z_calculation(2), BABYJUB_P);
        vars.Z_beta_3 = mulmod(mulmod(vars.Z_beta_2, beta, BABYJUB_P), z_calculation(3), BABYJUB_P);
        vars.Z_beta_4 = mulmod(mulmod(vars.Z_beta_3, beta, BABYJUB_P), z_calculation(4), BABYJUB_P);
        uint256 Z_beta_5 = mulmod(mulmod(vars.Z_beta_4, beta, BABYJUB_P), z_calculation(5), BABYJUB_P);
        uint256 Z_beta_6 = mulmod(mulmod(Z_beta_5, beta, BABYJUB_P), z_calculation(6), BABYJUB_P);
        uint256 Z_beta_7 = mulmod(mulmod(Z_beta_6, beta, BABYJUB_P), z_calculation(7), BABYJUB_P);
        
        // H calculation
        Pairing.G1Point memory H = Pairing.plus(Pairing.plus(Pairing.mulScalar(cm.D, vars.Z_beta_1), Pairing.mulScalar(cm.R_tilde, vars.Z_beta_2)), Pairing.mulScalar(cm.R, vars.Z_beta_3));
        H = Pairing.plus(H, Pairing.mulScalar(cm.T, vars.Z_beta_4));
        H = Pairing.plus(H, Pairing.mulScalar(cm.K, Z_beta_5));
        H = Pairing.plus(H, Pairing.mulScalar(cm.S_x, Z_beta_6));
        H = Pairing.plus(H, Pairing.mulScalar(cm.S_y, Z_beta_7));

        // R calculation, denoted  RR because already have a R for one Fcommitment
        // first calculate the PI product, and to do this first calculate the power of g after product to reduce gas cost
        uint256 power = mulmod(vars.Z_beta_1, BABYJUB_P - cm.gamma1[0], BABYJUB_P);
        power = addmod(power, mulmod(vars.Z_beta_2, BABYJUB_P - cm.gamma2[0], BABYJUB_P), BABYJUB_P);
        power = addmod(power, mulmod(vars.Z_beta_3, BABYJUB_P - addmod(cm.gamma3[0], mulmod(cm.gamma3[1], z, BABYJUB_P), 
                                                                BABYJUB_P), BABYJUB_P), BABYJUB_P);
        power = addmod(power, mulmod(vars.Z_beta_4, BABYJUB_P - cm.gamma4[0], BABYJUB_P), BABYJUB_P);
        // power = addmod(power, mulmod(Z_beta_4, BABYJUB_P - addmod(addmod(gamma4[0], 
        //                                                                         mulmod(gamma4[1], z, BABYJUB_P), 
        //                                                                         BABYJUB_P),
        //                                                                         mulmod(gamma4[2], 
        //                                                                         mulmod(z, z, 
        //                                                                         BABYJUB_P), 
        //                                                         BABYJUB_P),
        //                                                     BABYJUB_P),
        //                             BABYJUB_P), BABYJUB_P);
        power = addmod(power, mulmod(Z_beta_5, BABYJUB_P - cm.gamma5[0], BABYJUB_P), BABYJUB_P);
        power = addmod(power, mulmod(Z_beta_6, BABYJUB_P - addmod(cm.gamma6[0], mulmod(cm.gamma6[1], z, BABYJUB_P), 
                                                                BABYJUB_P), BABYJUB_P), BABYJUB_P);
        power = addmod(power, mulmod(Z_beta_7, BABYJUB_P - cm.gamma7[0], BABYJUB_P), BABYJUB_P);
        // calculate the PI product
        Pairing.G1Point memory RR = Pairing.mulScalar(Pairing.G1Point(1, 2), power);

        // then add the first item before the uppercase Pi product
        //g^p[x]·zT[z]
        RR = Pairing.plus(RR, Pairing.negate(Pairing.plus(cm.pi_1,
                                                        Pairing.mulScalar(Pairing.G1Point(1, 2),
                                                                        z_calculation(9)))));
        //g^z·w[x]
        RR = Pairing.plus(RR, Pairing.mulScalar(cm.pi_2, z));
        
        // check the equation, then check others
        // bool result = Pairing.pairing_3point(
        //     H,
        //     SRS_G2_1,
        //     RR,
        //     t_hxdmax,
        //     Pairing.negate(cm.pi_2),
        //     t_hxdmaxplusone
        //     )
        //     && recover(cm.message, cm.sig) == cm.addr //verifySignature
        //     && cm.r_1 == addmod(cm.r_tilde, mulmod(d, z_n, BABYJUB_P), BABYJUB_P)
        //     && cm.t == addmod(mulmod(cm.r_1, 
        //                           addmod(cm.r_2,
        //                                  cm.s_tilde, BABYJUB_P), BABYJUB_P),
        //                     (BABYJUB_P - cm.k), BABYJUB_P)
        //     && cm.s_1_tilde == cm.s_2_tilde;

        // temporary code for estimating gas cost, the above is correct version
        bool result = Pairing.pairing_3point(
            H,
            SRS_G2_1,
            RR,
            t_hxdmax,
            Pairing.negate(cm.pi_2),
            t_hxdmaxplusone
            );
        result = recover(cm.message, cm.sig) == cm.addr; //verifySignature
        result = cm.r_1 == addmod(cm.r_tilde, mulmod(d, z_n, BABYJUB_P), BABYJUB_P);
        result = cm.t == addmod(mulmod(cm.r_1, 
                                  addmod(cm.r_2,
                                         cm.s_tilde, BABYJUB_P), BABYJUB_P),
                            (BABYJUB_P - cm.k), BABYJUB_P);
        result = cm.s_1_tilde == cm.s_2_tilde;

        emit verifyResult(result);
        return result;
    }
    

    function z_calculation (uint256 i)
                            internal view returns (uint256){
        
        uint256 result = 1;
        if (i != 1){
            result = mulmod(result, addmod(z, BABYJUB_P - [z][0], BABYJUB_P), BABYJUB_P);
        }
        if (i != 2){
            result = mulmod(result, addmod(z, BABYJUB_P - [z][0], BABYJUB_P), BABYJUB_P);
        }
        if (i != 3){
            result = mulmod(mulmod(result, addmod(z, BABYJUB_P - [z, yz][1], BABYJUB_P), BABYJUB_P)
                            , addmod(z, BABYJUB_P - [z, yz][0], BABYJUB_P), BABYJUB_P);
        }
        if (i != 4){
            result = mulmod(result, addmod(z, BABYJUB_P - [z][0], BABYJUB_P), BABYJUB_P);
            // result = mulmod(mulmod(mulmod(result, addmod(z, BABYJUB_P - [z][2], BABYJUB_P), BABYJUB_P)
            //                 , addmod(z, BABYJUB_P - [z][1], BABYJUB_P), BABYJUB_P)
            //                 , addmod(z, BABYJUB_P - [z][0], BABYJUB_P), BABYJUB_P);
        }
        if (i != 5){
            result = mulmod(result, addmod(z, BABYJUB_P - [y][0], BABYJUB_P), BABYJUB_P);
        }
        if (i != 6){
            result = mulmod(mulmod(result, addmod(z, BABYJUB_P - [z, 1][1], BABYJUB_P), BABYJUB_P)
                            , addmod(z, BABYJUB_P - [z, 1][0], BABYJUB_P), BABYJUB_P);
        }
        if (i != 7){
            result = mulmod(result, addmod(z, BABYJUB_P - [y][0], BABYJUB_P), BABYJUB_P);
        }
        return result;
    }

    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 _v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            _v := byte(0, mload(add(signature, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (_v < 27) {
            _v += 27;
        }

        // If the version is correct return the signer address
        if (_v != 27 && _v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, _v, r, s);
        }
    }

    /**
    * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:" and hash the result
    */
    function ethMessageHash(string memory rawCommitment) internal pure returns (bytes32) {
        return keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(rawCommitment)))
        );
    }


    //     /*
    //  * @return The polynominal evaluation of a polynominal with the specified
    //  *         coefficients at the given index.
    //  */
    //  function evalPoly() public view returns (uint256) {

    //     uint baseOrder = 204;
    //     uint length = 64;
    //     uint256 _index = y;
    //     uint256 m = BABYJUB_P;
    //     uint256 result = 0;
    //     uint256 powerOfX = 1;

    //     for (uint256 i = 0; i < length; i ++) {
    //         assembly {
    //             result:= addmod(result, mulmod(powerOfX, i, m), m)
    //             powerOfX := mulmod(powerOfX, i, m)
    //         }
    //     }
    //     uint256 basePower = invMod(expMod(_index, baseOrder, m), m);
    //     result = mulmod(basePower, result, m);

    //     return result;
    // }

    /// @dev Modular euclidean inverse of a number (mod p).
    /// @param _x The number
    /// @param _pp The modulus
    /// @return q such that x*q = 1 (mod _pp)
    // function invMod(uint256 _x, uint256 _pp) internal pure returns (uint256) {
    //     require(_x != 0 && _x != _pp && _pp != 0, "Invalid number");
    //     uint256 q = 0;
    //     uint256 newT = 1;
    //     uint256 r = _pp;
    //     uint256 t;
    //     while (_x != 0) {
    //     t = r / _x;
    //     (q, newT) = (newT, addmod(q, (_pp - mulmod(t, newT, _pp)), _pp));
    //     (r, _x) = (_x, r - t * _x);
    //     }

    //     return q;
    // }

    /// @dev Modular exponentiation, b^e % _pp.
    /// Source: https://github.com/androlo/standard-contracts/blob/master/contracts/src/crypto/ECCMath.sol
    /// @param _base base
    /// @param _exp exponent
    /// @param _pp modulus
    /// @return r such that r = b**e (mod _pp)
    function expMod(uint256 _base, uint256 _exp, uint256 _pp) internal pure returns (uint256) {
        require(_pp!=0, "Modulus is zero");

        if (_base == 0)
        return 0;
        if (_exp == 0)
        return 1;

        uint256 r = 1;
        uint256 bit = 57896044618658097711785492504343953926634992332820282019728792003956564819968; // 2 ^ 255
        assembly {
        for { } gt(bit, 0) { }{
            // a touch of loop unrolling for 20% efficiency gain
            r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, bit)))), _pp)
            r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 2))))), _pp)
            r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 4))))), _pp)
            r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 8))))), _pp)
            bit := div(bit, 16)
        }
        }

        return r;
    }
    

}