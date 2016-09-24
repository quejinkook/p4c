#include <core.p4>
#include <v1model.p4>

header len_or_type_t {
    bit<48> value;
}

header mac_da_t {
    bit<48> mac;
}

header mac_sa_t {
    bit<48> mac;
}

struct metadata {
}

struct headers {
    @name("len_or_type") 
    len_or_type_t len_or_type;
    @name("mac_da") 
    mac_da_t      mac_da;
    @name("mac_sa") 
    mac_sa_t      mac_sa;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("parse_len_or_type") state parse_len_or_type {
        packet.extract<len_or_type_t>(hdr.len_or_type);
        transition accept;
    }
    @name("parse_mac_da") state parse_mac_da {
        packet.extract<mac_da_t>(hdr.mac_da);
        transition parse_mac_sa;
    }
    @name("parse_mac_sa") state parse_mac_sa {
        packet.extract<mac_sa_t>(hdr.mac_sa);
        transition parse_len_or_type;
    }
    @name("start") state start {
        transition parse_mac_da;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("nop") action nop_0() {
    }
    @name("t2") table t2_0() {
        actions = {
            nop_0();
            NoAction();
        }
        key = {
            hdr.mac_sa.mac: exact;
        }
        default_action = NoAction();
    }
    apply {
        t2_0.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name("nop") action nop_1() {
    }
    @name("t1") table t1_0() {
        actions = {
            nop_1();
            NoAction();
        }
        key = {
            hdr.mac_da.mac       : exact;
            hdr.len_or_type.value: exact;
        }
        default_action = NoAction();
    }
    apply {
        t1_0.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<mac_da_t>(hdr.mac_da);
        packet.emit<mac_sa_t>(hdr.mac_sa);
        packet.emit<len_or_type_t>(hdr.len_or_type);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
