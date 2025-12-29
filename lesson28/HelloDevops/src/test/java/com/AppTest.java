package com;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class AppTest {
    @Test
    void testGetMessage() {
        App app = new App();
        assertNotNull(app.getMessage());
        assertTrue(app.getMessage().startsWith("Hello"));
    }
}
