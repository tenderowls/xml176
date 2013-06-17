package ;

import com.tenderowls.xml176.TokenizerTest;
import haxe.unit.TestRunner;
class XML176TestRunner {

    public static function main() {
        var runner = new TestRunner();
        runner.add(new TokenizerTest());
        runner.run();
    }
}
