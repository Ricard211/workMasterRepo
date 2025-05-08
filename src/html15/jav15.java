public class TuringMachine {
    public static void main(String[] args) {
        String tape = "1101"; // Input tape
        char[] tapeArray = tape.toCharArray();
        int head = 0; // Head position
        String state = "q0"; // Initial state

        while (!state.equals("halt")) {
            char currentSymbol = tapeArray[head];
            switch (state) {
                case "q0":
                    if (currentSymbol == '1') {
                        tapeArray[head] = '0';
                        head++;
                        state = "q1";
                    } else if (currentSymbol == '0') {
                        tapeArray[head] = '1';
                        head++;
                        state = "q2";
                    }
                    break;
                case "q1":
                    if (currentSymbol == '1') {
                        tapeArray[head] = '1';
                        head++;
                        state = "halt";
                    }
                    break;
                case "q2":
                    if (currentSymbol == '0') {
                        tapeArray[head] = '0';
                        head++;
                        state = "halt";
                    }
                    break;
                default:
                    state = "halt";
                    break;
            }
        }

        System.out.println("Final Tape: " + new String(tapeArray));
    }
}