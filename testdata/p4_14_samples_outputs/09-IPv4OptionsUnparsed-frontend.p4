header ipv4_t_1 {
    bit<4>  version;
    bit<4>  ihl;
    bit<8>  diffserv;
    bit<16> totalLen;
    bit<16> identification;
    bit<1>  reserved_0;
    bit<1>  df;
    bit<1>  mf;
    bit<13> fragOffset;
    bit<8>  ttl;
    bit<8>  protocol;
    bit<16> hdrChecksum;
    bit<32> srcAddr;
    bit<32> dstAddr;
}

header ipv4_t_2 {
    varbit<352> options;
}

#include <core.p4>
#include <v1model.p4>

header ethernet_t {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> ethertype;
}

header ipv4_t {
    bit<4>      version;
    bit<4>      ihl;
    bit<8>      diffserv;
    bit<16>     totalLen;
    bit<16>     identification;
    bit<1>      reserved_0;
    bit<1>      df;
    bit<1>      mf;
    bit<13>     fragOffset;
    bit<8>      ttl;
    bit<8>      protocol;
    bit<16>     hdrChecksum;
    bit<32>     srcAddr;
    bit<32>     dstAddr;
    @length(ihl << 2) 
    varbit<352> options;
}

header vlan_tag_t {
    bit<3>  pcp;
    bit<1>  cfi;
    bit<12> vlan_id;
    bit<16> ethertype;
}

struct metadata {
}

struct headers {
    @name("ethernet") 
    ethernet_t    ethernet;
    @name("ipv4") 
    ipv4_t        ipv4;
    @name("vlan_tag") 
    vlan_tag_t[2] vlan_tag;
}

parser ParserImpl(packet_in packet, out headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    ipv4_t_1 tmp_hdr_1;
    ipv4_t_2 tmp_hdr_2;
    @name("parse_ethernet") state parse_ethernet {
        packet.extract<ethernet_t>(hdr.ethernet);
        transition select(hdr.ethernet.ethertype) {
            16w0x8100 &&& 16w0xefff: parse_vlan_tag;
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name("parse_ipv4") state parse_ipv4 {
        packet.extract<ipv4_t_1>(tmp_hdr_1);
        packet.extract<ipv4_t_2>(tmp_hdr_2, (bit<32>)(tmp_hdr_1.ihl << 2));
        hdr.ipv4.setValid();
        hdr.ipv4.version = tmp_hdr_1.version;
        hdr.ipv4.ihl = tmp_hdr_1.ihl;
        hdr.ipv4.diffserv = tmp_hdr_1.diffserv;
        hdr.ipv4.totalLen = tmp_hdr_1.totalLen;
        hdr.ipv4.identification = tmp_hdr_1.identification;
        hdr.ipv4.reserved_0 = tmp_hdr_1.reserved_0;
        hdr.ipv4.df = tmp_hdr_1.df;
        hdr.ipv4.mf = tmp_hdr_1.mf;
        hdr.ipv4.fragOffset = tmp_hdr_1.fragOffset;
        hdr.ipv4.ttl = tmp_hdr_1.ttl;
        hdr.ipv4.protocol = tmp_hdr_1.protocol;
        hdr.ipv4.hdrChecksum = tmp_hdr_1.hdrChecksum;
        hdr.ipv4.srcAddr = tmp_hdr_1.srcAddr;
        hdr.ipv4.dstAddr = tmp_hdr_1.dstAddr;
        hdr.ipv4.options = tmp_hdr_2.options;
        transition accept;
    }
    @name("parse_vlan_tag") state parse_vlan_tag {
        packet.extract<vlan_tag_t>(hdr.vlan_tag.next);
        transition select(hdr.vlan_tag.last.ethertype) {
            16w0x8100 &&& 16w0xefff: parse_vlan_tag;
            16w0x800: parse_ipv4;
            default: accept;
        }
    }
    @name("start") state start {
        transition parse_ethernet;
    }
}

control egress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".nop") action nop_0() {
    }
    @name("t2") table t2_0 {
        actions = {
            nop_0();
            @defaultonly NoAction();
        }
        key = {
            hdr.ethernet.srcAddr: exact @name("hdr.ethernet.srcAddr") ;
        }
        default_action = NoAction();
    }
    apply {
        t2_0.apply();
    }
}

control ingress(inout headers hdr, inout metadata meta, inout standard_metadata_t standard_metadata) {
    @name(".nop") action nop_1() {
    }
    @name("t1") table t1_0 {
        actions = {
            nop_1();
            @defaultonly NoAction();
        }
        key = {
            hdr.ethernet.dstAddr: exact @name("hdr.ethernet.dstAddr") ;
        }
        default_action = NoAction();
    }
    apply {
        t1_0.apply();
    }
}

control DeparserImpl(packet_out packet, in headers hdr) {
    apply {
        packet.emit<ethernet_t>(hdr.ethernet);
        packet.emit<vlan_tag_t[2]>(hdr.vlan_tag);
        packet.emit<ipv4_t>(hdr.ipv4);
    }
}

control verifyChecksum(in headers hdr, inout metadata meta) {
    apply {
    }
}

control computeChecksum(inout headers hdr, inout metadata meta) {
    apply {
    }
}

V1Switch<headers, metadata>(ParserImpl(), verifyChecksum(), ingress(), egress(), computeChecksum(), DeparserImpl()) main;
