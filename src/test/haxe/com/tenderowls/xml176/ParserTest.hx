package com.tenderowls.xml176;

import com.tenderowls.xml176.XML176Document;
import com.tenderowls.xml176.Tokenizer;
import com.tenderowls.xml176.Parser;

import haxe.unit.TestCase;

class ParserTest extends TestCase {

    public function testBasic() {

        var p = { file: "unknow", min: 0, max: 1 }

        var parser = new Parser( [
            Token.OpenTag(p), Token.Literal("node",p), Token.CloseTag(p),
            Token.OpenTag(p), Token.Slash(p), Token.Literal("node",p), Token.CloseTag(p)
        ]);

        var expected = [ XML176Document.Node(new QName(null, "node"), new Array<XML176Document>(), p) ];
        var actual = [ parser.parse() ];

        assertEquals(expected.toString(), actual.toString());
    }

    public function testAttrs() {

        var p = { file: "unknow", min: 0, max: 1 }

        var parser = new Parser( [
            Token.OpenTag(p), Token.Literal("node",p), Token.Whitespace(1, p),
            Token.Literal("attr1", p), Token.Equals(p), Token.DoubleQuote(p), Token.Literal("value", p),Token.DoubleQuote(p), Token.Whitespace(1, p),
            Token.Literal("attr2", p), Token.Equals(p), Token.DoubleQuote(p), Token.Literal("value", p),Token.DoubleQuote(p),
            Token.CloseTag(p),
            Token.OpenTag(p), Token.Slash(p), Token.Literal("node",p), Token.CloseTag(p)
        ]);

        var expected = [
            XML176Document.Node(
                new QName(null, "node"), [
                    XML176Document.Attr(new QName(null, "attr1"), "value", p),
                    XML176Document.Attr(new QName(null, "attr2"), "value", p)
                ],
                p
            )
        ];
        var actual = [ parser.parse() ];

        assertEquals(expected.toString(), actual.toString());
    }
}
