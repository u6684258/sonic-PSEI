// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

library Pairing {

    uint256 constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    struct G1Point {
        uint256 X;
        uint256 Y;
    }

    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint256[2] X;
        uint256[2] Y;
    }

    /*
     * @return The negation of p, i.e. p.plus(p.negate()) should be zero. 
     */
    function negate(G1Point memory p) internal pure returns (G1Point memory) {

        // The prime q in the base field F_q for G1
        if (p.X == 0 && p.Y == 0) {
            return G1Point(0, 0);
        } else {
            return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }
    }

    /*
     * @return The sum of two points of G1
     */
    function plus(
        G1Point memory p1,
        G1Point memory p2
    ) internal view returns (G1Point memory r) {

        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require(success, "pairing-add-failed");
    }

    /*
     * @return The point multiplication of p and q. 
     */
    function MulPoint(G1Point memory p, G1Point memory q) internal pure returns (G1Point memory) {

        // The prime q in the base field F_q for G1
        return G1Point(mulmod(p.X, q.X, PRIME_Q), mulmod(p.Y, q.Y, PRIME_Q));
        
    }

    /*
     * @return The product of a point on G1 and a scalar, i.e.
     *         p == p.scalar_mul(1) and p.plus(p) == p.scalar_mul(2) for all
     *         points p.
     */
    function mulScalar(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {

        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success, "pairing-mul-failed");
    }

    /* @return The result of computing the pairing check
     *         e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
     *         For example,
     *         pairing([P1(), P1().negate()], [P2(), P2()]) should return true.
     */
    function pairing(
        G1Point memory a1,
        G2Point memory a2,
        G1Point memory b1,
        G2Point memory b2,
        G1Point memory c1,
        G2Point memory c2
    ) internal view returns (bool) {

        G1Point[3] memory p1 = [a1, b1, c1];
        G2Point[3] memory p2 = [a2, b2, c2];

        uint256 inputSize = 18;
        uint256[] memory input = new uint256[](inputSize);

        for (uint256 i = 0; i < 3; i++) {
            uint256 j = i * 6;
            input[j + 0] = p1[i].X;
            input[j + 1] = p1[i].Y;
            input[j + 2] = p2[i].X[0];
            input[j + 3] = p2[i].X[1];
            input[j + 4] = p2[i].Y[0];
            input[j + 5] = p2[i].Y[1];
        }

        uint256[1] memory out;
        bool success;
        uint256 len = inputSize * 0x20;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := staticcall(sub(gas(), 2000), 0x8, add(input, 0x20), len, out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success, "pairing-opcode-failed");

        return out[0] != 0;
        // return true;
    }
    /// return the result of computing the pairing check
	/// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
	/// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
	/// return true.
	// function pairing(G1Point[] memory p1, G2Point[] memory p2) internal returns (bool) {
	// 	require(p1.length == p2.length);
	// 	uint elements = p1.length;
	// 	uint inputSize = elements * 6;
	// 	uint[] memory input = new uint[](inputSize);
	// 	for (uint i = 0; i < elements; i++)
	// 	{
	// 		input[i * 6 + 0] = p1[i].X;
	// 		input[i * 6 + 1] = p1[i].Y;
	// 		input[i * 6 + 2] = p2[i].X[0];
	// 		input[i * 6 + 3] = p2[i].X[1];
	// 		input[i * 6 + 4] = p2[i].Y[0];
	// 		input[i * 6 + 5] = p2[i].Y[1];
	// 	}
	// 	uint[1] memory out;
	// 	bool success;
	// 	assembly {
	// 		success := call(not(0), 8, 0, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
    //     }
	// 	require(success);
	// 	return out[0] != 0;
    //     // return false;
	// }
    
    // function pairingProd3(
	// 		G1Point memory a1, G2Point memory a2,
	// 		G1Point memory b1, G2Point memory b2,
	// 		G1Point memory c1, G2Point memory c2
	// ) internal returns (bool) {
	// 	G1Point[] memory p1 = new G1Point[](3);
	// 	G2Point[] memory p2 = new G2Point[](3);
	// 	p1[0] = a1;
	// 	p1[1] = b1;
	// 	p1[2] = c1;
	// 	p2[0] = a2;
	// 	p2[1] = b2;
	// 	p2[2] = c2;
	// 	return pairing(p1, p2);
	// }
}
