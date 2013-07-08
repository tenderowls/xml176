package com.tenderowls.xml176;

import com.tenderowls.xml176.Xml176Parser.Xml176Document;

class Xml176ParserTest extends haxe.unit.TestCase {

    public function testNode() {
        var doc:Xml176Document = Xml176Parser.parse("<Node></Node>");
        assertEquals(
            Std.string(doc.getNodePosition(doc.document.firstChild())),
            Std.string({from:1, to:5})
        );
    }

    public function testAttr() {
        var doc:Xml176Document = Xml176Parser.parse("<Node attr=\"value\"></Node>");
        assertEquals(
            Std.string(doc.getAttrPosition(doc.document.firstChild(), "attr")),
            Std.string({from:7, to:11})
        );
    }
}
