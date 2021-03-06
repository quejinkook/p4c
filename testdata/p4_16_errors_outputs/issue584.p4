#include <core.p4>
#include <v1model.p4>

typedef bit<16> Hash;
control p();
package top(p _p);
control c() {
    apply {
        bit<16> var;
        bit<32> hdr = 0;
        hash(var, HashAlgorithm.crc16, 0, hdr, 0xffff);
    }
}

top(c()) main;
