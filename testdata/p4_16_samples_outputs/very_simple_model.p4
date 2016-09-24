#include <core.p4>

typedef bit<4> PortId;
const PortId REAL_PORT_COUNT = 4w8;
struct InControl {
    PortId inputPort;
}

const PortId RECIRCULATE_IN_PORT = 0xd;
const PortId CPU_IN_PORT = 0xe;
struct OutControl {
    PortId outputPort;
}

const PortId DROP_PORT = 0xf;
const PortId CPU_OUT_PORT = 0xe;
const PortId RECIRCULATE_OUT_PORT = 0xd;
parser Parser<H>(packet_in b, out H parsedHeaders);
control Pipe<H>(inout H headers, in error parseError, in InControl inCtrl, out OutControl outCtrl);
control Deparser<H>(inout H outputHeaders, packet_out b);
package VSS<H>(Parser<H> p, Pipe<H> map, Deparser<H> d);
extern Checksum16 {
    void clear();
    void update<T>(in T data);
    bit<16> get();
}

