// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./Pairing.sol";
/*
 * The values in this file come from challenge file #46 of the Perpetual Powers
 * of Tau ceremony. The Blake2b hash of challenge file is:
 *
 * 939038cd 2dc5a1c0 20f368d2 bfad8686 
 * 950fdf7e c2d2e192 a7d59509 3068816b
 * becd914b a293dd8a cb6d18c7 b5116b66 
 * ea54d915 d47a89cc fbe2d5a3 444dfbed
 *
 * The challenge file can be retrieved at:
 * https://ppot.blob.core.windows.net/public/challenge_0046
 *
 * The ceremony transcript can be retrieved at:
 * https://github.com/weijiekoh/perpetualpowersoftau
 *
 * Anyone can verify the transcript to ensure that the values in the challenge
 * file have not been tampered with. Moreover, as long as one participant in
 * the ceremony has discarded their toxic waste, the whole ceremony is secure.
 * Please read the following for more information:
 * https://medium.com/coinmonks/announcing-the-perpetual-powers-of-tau-ceremony-to-benefit-all-zk-snark-projects-c3da86af8377
 */

contract Constants {
    // using Pairing for *;

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
    uint256 constant BABYJUB_P = 21888242871839275222246405745257275088548364400416034343698204186575808495617;

    // The G1 generator
    function G1Gen() pure internal returns (Pairing.G1Point memory) {
        return Pairing.G1Point(1, 2);
    }
    // the G2Gen() doesn't work in verify() for unknown reason
    function G2Gen() pure internal returns (Pairing.G2Point memory) {
        return Pairing.G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    // index 0 for SRSLocal, 1..n for SRSRaw. In this instance n = 1.
    function SRS_G2_hAlphaX1(uint i) view internal returns (Pairing.G2Point memory) {
        return Pairing.G2Point({
            X: [ SRS_G2_X_0_Pos[2*i], SRS_G2_X_1_Pos[2*i] ],
            Y: [ SRS_G2_Y_0_Pos[2*i], SRS_G2_Y_1_Pos[2*i] ]
        });
    }
    // index 0 for SRSLocal, 1..n for SRSRaw. In this instance n = 1.
    function SRS_G2_hAlphaX0(uint i) view internal returns (Pairing.G2Point memory) {
        return Pairing.G2Point({
            X: [ SRS_G2_X_0_Pos[2*i+1], SRS_G2_X_1_Pos[2*i+1] ],
            Y: [ SRS_G2_Y_0_Pos[2*i+1], SRS_G2_Y_1_Pos[2*i+1] ]
        });
    }
    // index 0 for SRSLocal, 1..n for SRSRaw. In this instance n = 1.
    function SRS_G2_hAlphaXdMax(uint i, bool isT) view internal returns (Pairing.G2Point memory) {
        if (isT) {
            return t_hxdmax;
        }
        else if (i == 0){
            return r_local_hxdmax;
        } else {
            return r_raw_hxdmax;
        }
        
    }

    uint256[] SRS_G2_X_0 = [
        uint256(0x198e9393920d483a7260bfb731fb5d25f1aa493335a9e71297e485b7aef312c2),
        uint256(0x21a808dad5c50720fb7294745cf4c87812ce0ea76baa7df4e922615d1388f25a)
    ];

    uint256[] SRS_G2_X_1 = [
        uint256(0x1800deef121f1e76426a00665e5c4479674322d4f75edadd46debd5cd992f6ed),
        uint256(0x04c5e74c85a87f008a2feb4b5c8a1e7f9ba9d8eb40eb02e70139c89fb1c505a9)
    ];

    uint256[] SRS_G2_Y_0 = [
        uint256(0x090689d0585ff075ec9e99ad690c3395bc4b313370b38ef355acdadcd122975b),
        uint256(0x204b66d8e1fadc307c35187a6b813be0b46ba1cd720cd1c4ee5f68d13036b4ba)
    ];

    uint256[] SRS_G2_Y_1 = [
        uint256(0x12c85ea5db8c6deb4aab71808dcb408fe3d1e7690c43d37b4ce6cc0166fa7daa),
        uint256(0x2d58022915fc6bc90e036e858fbc98055084ac7aff98ccceb0e3fde64bc1a084)
    ];

    uint256[] SRS_G2_X_0_Pos = [
        uint256(11918255060517660340153982215726798826640678374023024552644116046404414986453),
        uint256(15624790064206502667756020446826209080711344272800176518784649088946231692936),
        uint256(11268695302917653497930368204518419275811373844270095345017116270039580435706),
        uint256(2443430939986969712743682923434644543094899517010817087050769422599268135103)
    ];

    uint256[] SRS_G2_X_1_Pos = [
        uint256(14727727513753126219856215163660015034576342086845264359489607457590808060078),
        uint256(8472151341754925747860535367990505955708751825377817860727104273184244800723),
        uint256(9753532634097748217842057100292196132812913888453919348849716624821506442403),
        uint256(14502447760486387799059318541209757040844770937862468921929310682431317530875)
        
    ];

    uint256[] SRS_G2_Y_0_Pos = [
        uint256(1021740485891650940618786211510896476185198195365756893837573927220126603539),
        uint256(19488077321171448217727198730828487286865984357780136663388739985720647978898),
        uint256(14776274355700936137709623009318398493759214126639684828506188800357268553876),
        uint256(4704672529862198727079301732358554332963871698433558481208245291096060730807)
        
    ];

    uint256[] SRS_G2_Y_1_Pos = [
        uint256(9391419861535979107512398044543127125134834662773960663727860605307747847262),
        uint256(1196137947243150610106053819405501111182787323156221967342356892090037828244),
        uint256(18234420836750160252624653416906661873432457147248720023481962812575477763504),
        uint256(11721331165636005533649329538372312212753336165656329339895621434122061690013)
        
    ];

    Pairing.G2Point r_raw_hxdmax = Pairing.G2Point(
        [11018496122438102807385926965630407879878991236962904047786654761679227167616,
        6687397713294771832164093012092950408243252863676129125992435652325996730602],
        [20298816527791824943274909266350631716562678769274418498194188929605815382657,
        7799408864707847932939125741785731794468695101009851163957118440823802818871]
    );

    Pairing.G2Point r_local_hxdmax = Pairing.G2Point(
        [7976430090925992890536185151910635582610031434267587807915311757199615446495,
        13899531392144220320309619623911912477202262683091307457103109724600197587445],
        [20411075118513893702806531153229965183145207612983771164765870508592897317695,
        11168048083216765600717976206319300122875749432541522572231484400367147406267]
    );
    
    Pairing.G2Point t_hxdmax = Pairing.G2Point(
        [11559732032986387107991004021392285783925812861821192530917403151452391805634,
        10857046999023057135944570762232829481370756359578518086990519993285655852781],
        [4082367875863433681332203403145435568316851327593401208105741076214120093531,
        8495653923123431417604973247489272438418190587263600148770280649306958101930]
    );
    uint256 constant srsD = 251;

    
}