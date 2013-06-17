package com.tenderowls.xml176;

import com.tenderowls.xml176.XML176;
import haxe.io.StringInput;
import haxe.unit.TestCase;

class TokenizerTest extends TestCase {

    inline static var u = "unknown";

    public function testTag() {

        var expected:Array<Token> = [
            Token.OpenTag({ file: u, min:0, max:1 }),
            Token.CloseTag({ file: u, min:1, max:2 }),
            Token.OpenTag({ file: u, min:2, max:3 }),
            Token.Slash({ file: u, min:3, max:4 }),
            Token.CloseTag({ file: u, min:4, max:5 })
        ];

        var actual:Array<Token> = new Array<Token>();

        for (t in new Tokenizer(new StringInput("<></>"), u)) {
            actual.push(t);
        }

        assertEquals(expected.toString(), actual.toString());
    }

    public function testTagWithLiteral() {

        var expected:Array<Token> = [
            Token.OpenTag({ file: u, min:0, max:1 }),
            Token.Literal("name", { file: u, min:1, max:5 }),
            Token.CloseTag({ file: u, min:5, max:6 }),
            Token.OpenTag({ file: u, min:8, max:9 }),
            Token.Slash({ file: u, min:9, max:10 }),
            Token.Literal("name", { file: u, min:10, max:14 }),
            Token.CloseTag({ file: u, min:14, max:15 })
        ];

        var actual:Array<Token> = new Array<Token>();

        for (t in new Tokenizer(new StringInput("<name>  </name>"), u)) {
            actual.push(t);
        }

        assertEquals(expected.toString(), actual.toString());
    }

    public function testTagWithLiteral() {

        var expected:Array<Token> = [
        Token.OpenTag({ file: u, min:0, max:1 }),
        Token.Literal("name", { file: u, min:1, max:5 }),
        Token.CloseTag({ file: u, min:5, max:6 }),
        Token.OpenTag({ file: u, min:8, max:9 }),
        Token.Slash({ file: u, min:9, max:10 }),
        Token.Literal("name", { file: u, min:10, max:14 }),
        Token.CloseTag({ file: u, min:14, max:15 })
        ];

        var actual:Array<Token> = new Array<Token>();

        for (t in new Tokenizer(new StringInput("[].,!?<>/\"\'"), u)) {
            actual.push(t);
        }

        assertEquals(expected.toString(), actual.toString());
    }

}

