package com.tenderowls.xml176;

import com.tenderowls.xml176.Tokenizer;
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
            Token.Whitespace(2, { file: u, min:6, max:8 }),
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

    public function testLiteralWithWhiteSpace() {

        var expected:Array<Token> = [
            Token.Literal("Hello", { file: u, min:0, max:5 }),
            Token.Whitespace(1, { file: u, min:5, max:6 }),
            Token.Literal("world", { file: u, min:6, max:11 }),
            Token.ExclamationMark({ file: u, min:11, max:12 })
        ];

        var actual:Array<Token> = new Array<Token>();

        for (t in new Tokenizer(new StringInput("Hello world!"), u)) {
            actual.push(t);
        }

        assertEquals(expected.toString(), actual.toString());
    }

    public function testNonLiteral() {

        var pos = 0;
        var expected:Array<Token> = [
            Token.SquareBracketLeft( { file: u, min: pos, max: ++pos } ),
            Token.SquareBracketRight( { file: u, min: pos, max: ++pos } ),
            Token.Dot( { file: u, min: pos, max: ++pos } ),
            Token.Comma( { file: u, min: pos, max: ++pos } ),
            Token.ExclamationMark( { file: u, min: pos, max: ++pos } ),
            Token.QuestionMark( { file: u, min: pos, max: ++pos } ),
            Token.OpenTag( { file: u, min: pos, max: ++pos } ),
            Token.CloseTag( { file: u, min: pos, max: ++pos } ),
            Token.Slash( { file: u, min: pos, max: ++pos } ),
            Token.DoubleQuote( { file: u, min: pos, max: ++pos } ),
            Token.SingleQuote( { file: u, min: pos, max: ++pos } )
        ];

        var actual:Array<Token> = new Array<Token>();

        for (t in new Tokenizer(new StringInput("[].,!?<>/\"\'"), u)) {
            actual.push(t);
        }

        assertEquals(expected.toString(), actual.toString());
    }

}

