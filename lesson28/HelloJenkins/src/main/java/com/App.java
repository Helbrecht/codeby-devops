package com;

/**
 * Hello Jenkins!
 */
public class App {
    private static final String MESSAGE = "Hello Jenkins! CODEBY TEST CHANGE";
    public App() {}
    public static void main(String[] args) {
        System.out.println(MESSAGE);
    }
    public String getMessage() {
        return MESSAGE;
    }
}
