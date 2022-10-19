// Modified from https://github.com/appliedzkp/semaphore/blob/master/contracts/sol/verifier.sol
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;
import "./Pairing.sol";
import { Constants } from "./Constants.sol";
// import "@openzeppelin/contracts/utils/Strings.sol";

contract Verifier is Constants {

    using Pairing for *;

    event verifyResult(bool result);

        uint256[21] Proof = [
        uint256(2430733905368895916701976989655953862896035771386717556982160819783711210259),
        uint256(9102689289354761110068331105410089518316055851359267235619562339144552714861),
        uint256(231014479782015245234485944771714376129960099757713828634132041508962534993),
        uint256(15099064614159299663080487230823884942440586700446010397106703856370686471325),
        uint256(10198615850236778191572580177241459532096537374239993203230156328960212711149),
        uint256(20854966057074177555524519608858250376341891606772696891343849640249819385526),
        uint256(6605909092223862648613968386402357480359451094900557075157385215695092952074),
        uint256(18472372209171503790441601420424676041484799620636246676248038256500873016088),
        uint256(6220787008916881319464370308587583513747649813889514713418153671677530961461),
        uint256(8410191156283576312133164019612153564612983502707137877846252398182429699611),
        uint256(1820001689768674135888951944656928058241513992531238138089549754609125119294),
        uint256(2481025605512560144389230622484540415228674859111262047132029184762560628755),
        uint256(12614326796259460332098117539257035477751183231136301969141385827893700191770),
        uint256(6056125761187849748353562446238980078619996597424387167604135170228008905344),
        uint256(1438753959943999162451315047167581830276659445368102511962701719477730368436),
        uint256(1989759524443601204692947738626334818861392328343249322352120588556964384700),
        uint256(4764924722803456286311178318372354491810275746966477090281148264867809032273),
        uint256(3756790786816475510002535058113872263686811807862191243886597789673842853469),
        uint256(18632317099518353147736879316131442557722213222436942659892786599050299898169),
        uint256(3250906048494115919264401473218909908097490254322898166638512619982074389160),
        uint256(18169683744246052594747345179909030548741561307324612991065700128574975702319)
    ];

    uint256[2] Randoms = [
        uint256(20748554516541903851893401240329527750480785079715456083281433659587182250826),
        uint256(17323628418251496212520547221003717179005341626515695250810504986175930344785)
    ];

    uint256 evalK = uint256(6107955905213222098911676322114463806190125380976743840977370452610947540634);
    uint256 evalS = Proof[20];

    // SOCC_hscS = [G1Point S_j, uint256 s_j, G1Point W_j]
    uint256[5] SOCC_hscS = [
        uint256(8336614892309485028849467793134923327156829985996982469921999618884819358776),
        uint256(17290899279085178024936961682249154968987397116301237179151550605443113560664),
        uint256(18169683744246052594747345179909030548741561307324612991065700128574975702319),
        uint256(2278468211751234646712135520919898219361960368572599019079972562160207294698),
        uint256(2420156036684871195688033984161764517471465559954831069502558639467666365679)
    ];
    // SOCC_hscW = [uint256 s'_j,G1Point W'_j, G1Point Q_j]
    uint256[5] SOCC_hscW = [
        uint256(8702330772908673544678514143802978245139883407827296227979754460248183114350),
        uint256(17926359916659905699556696996276133538058455684840102529224327278061418884717),
        uint256(9895040669229526741117904727812823634582492611498587562463411105945646489431),
        uint256(4947190002820093267899730441996921991882734347194954849846175079133624862702),
        uint256(17737945086681349098252848496937276901600675156251938510370979269949725548707)
    ];

    Pairing.G1Point hscQv = Pairing.G1Point(
        uint256(12700359451261376939236228318139409828644131707895034570361970225488483343448),
        uint256(11544898578886980549803566157426707547167181914929290408430550390469018298142)
    );
    Pairing.G1Point hscC = Pairing.G1Point(
        uint256(9441135556124043806916187484539565100183345165257292117673036998730723044275),
        uint256(5869639566566113220789863422799500968026057473505251183319867188056795646426)
    );

    uint256 u = uint256(20487330288252882171410724243653372084954338721269411052281427881862306732523);
    uint256 v = uint256(20105232964311582578824171353106690547034178131939785538492689354042317227169);

    // from terminal
    uint256 s_uv = uint256(4119086359917066269382802373150874671712346973043070050093647525174658361025);

    // from Go
    bytes32 message = ethMessageHash("231014479782015245234485944771714376129960099757713828634132041508962534993, 10198615850236778191572580177241459532096537374239993203230156328960212711149");
    bytes sig = hex"5965bd77ef5fdd9db27103492c1c0fa491feff7a5391a32e4160f0fe135988e70d53409fa2fb6a2e374ccfdf33196e88dc258f3172d2366e6a2e3039d504166b01";
    address addr = 0xa2F2f34cc9D9646A57Ec5B95761a367abdD73d2a;



    function verify(
        Pairing.G1Point memory _commitment, // F
        Pairing.G1Point memory _proof, // W
        uint256 _index,  // z
        uint256 _value,  // F(z) or v
        uint proofIndex,
        bool isT
    ) public view returns (bool) {
        // Make sure each parameter is less than the prime q
        require(_commitment.X < BABYJUB_P, "Verifier.verifyKZG: _commitment.X is out of range");
        require(_commitment.Y < BABYJUB_P, "Verifier.verifyKZG: _commitment.Y is out of range");
        require(_proof.X < BABYJUB_P, "Verifier.verifyKZG: _proof.X is out of range");
        require(_proof.Y < BABYJUB_P, "Verifier.verifyKZG: _proof.Y is out of range");
        require(_index < BABYJUB_P, "Verifier.verifyKZG: _index is out of range");
        require(_value < BABYJUB_P, "Verifier.verifyKZG: _value is out of range");
       
        Pairing.G1Point memory negProof = Pairing.negate(Pairing.mulScalar(_proof, _index));
        Pairing.G1Point memory mulProof = Pairing.plus(Pairing.mulScalar(Constants.G1Gen(), _value), negProof);
        Pairing.G1Point memory negCm = Pairing.negate(_commitment);

        return Pairing.pairing(_proof, Constants.SRS_G2_hAlphaX1(proofIndex),
                                mulProof, Constants.SRS_G2_hAlphaX0(proofIndex),
                                negCm, Constants.SRS_G2_hAlphaXdMax(proofIndex, isT));
        // return false;
    }

    function verifySonic(
        // uint256[21] memory Proof,
        // uint256[2] memory Randoms
    ) public returns (bool) {

        uint256 yz = mulmod(Randoms[0], Randoms[1], Pairing.BABYJUB_P);
        uint256 t = addmod(mulmod(addmod(Proof[6], Proof[9], Pairing.BABYJUB_P), 
                                  addmod(addmod(Proof[12], 
                                                Proof[15], Pairing.BABYJUB_P), 
                                         evalS, Pairing.BABYJUB_P), Pairing.BABYJUB_P),
                            Pairing.BABYJUB_P - evalK, Pairing.BABYJUB_P);

        bool verifySignature = recover(message, sig) == addr;
        bool result = verify(Pairing.G1Point(Proof[0], Proof[1]), // aLocal
                      Pairing.G1Point(Proof[7], Proof[8]),
                      Randoms[1], 
                      Proof[6],
                      0, false) &&
                verify(Pairing.G1Point(Proof[0], Proof[1]), // bLocal
                      Pairing.G1Point(Proof[13], Proof[14]),
                      yz,
                      Proof[12],
                      0, false) &&
                verify(Pairing.G1Point(Proof[2], Proof[3]), // aRaw
                      Pairing.G1Point(Proof[10], Proof[11]),
                      Randoms[1],
                      Proof[9],
                      1, false) &&
                verify(Pairing.G1Point(Proof[2], Proof[3]), // bRaw
                      Pairing.G1Point(Proof[16], Proof[17]),
                      yz,
                      Proof[15],
                      1, false) &&
                verify(Pairing.G1Point(Proof[4], Proof[5]), // t
                      Pairing.G1Point(Proof[18], Proof[19]),
                      Randoms[1],
                      t,
                      0, true) && 
                verifySOCC() && verifySignature;
        // bool result = true;
        emit verifyResult(result);
        return result;
    }

    function verifySOCC() public returns (bool) {

        bool verified = verify(Pairing.G1Point(SOCC_hscS[0], SOCC_hscS[1]), // pcV(bp,srs,S_j,d,z_j,(s_j,W_j)
                      Pairing.G1Point(SOCC_hscS[3], SOCC_hscS[4]),
                      Randoms[1], 
                      SOCC_hscS[2],
                      0, true) &&
                      verify(Pairing.G1Point(SOCC_hscS[0], SOCC_hscS[1]), // pcV(bp,srs,S_j,d,u,(s'_j,W'_j))
                      Pairing.G1Point(SOCC_hscW[1], SOCC_hscW[2]),
                      u, 
                      SOCC_hscW[0],
                      0, true) &&
                      verify(hscC,                                      // pcV(bp,srs,C,d,y_j,(s'_j,Q_j)
                      Pairing.G1Point(SOCC_hscW[3], SOCC_hscW[4]),
                      Randoms[0], 
                      SOCC_hscW[0],
                      0, true) &&
                      verify(hscC,                                      // pcV(bp,srs,C,d,v,(s_uv,Q_v))
                      hscQv,
                      v, 
                      s_uv,
                      0, true);
        emit verifyResult(verified);
        return verified;
    }

    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

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
            v := byte(0, mload(add(signature, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
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

}