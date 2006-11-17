package javafish.clients.opc;

import javafish.clients.opc.browser.JOpcBrowserTest;
import javafish.clients.opc.variant.VariantTest;
import junit.framework.Test;
import junit.framework.TestSuite;

/**
 * A test suite for all tests related to the JEaseOpc framework.
 */
public final class AllUnitTests {
    public static void main(String[] args) {
        junit.textui.TestRunner.run(AllUnitTests.suite());
    }

    public static Test suite() {
        TestSuite suite = new TestSuite("Test for javafish.client.opc");
        // add all unit tests
        suite.addTest(new TestSuite(JCustomOpcTest.class));
        suite.addTest(new TestSuite(JOpcBrowserTest.class));
        suite.addTest(new TestSuite(JOpcTest.class));
        suite.addTest(new TestSuite(JEasyOpcTest.class));
        suite.addTest(new TestSuite(VariantTest.class));
        
        return suite;
    }
}

