import java.util.HashSet;
import java.util.Set;

public class Main {

    public static void main(String[] args) {
        int initialValue = 0x1E37;
        int period = calculatePeriod(initialValue);
        System.out.println("Period: " + period);
    }

    public static int calculatePeriod(int initialValue) {
        int value;
        int finalValue = initialValue;
        Set<Integer> valuesSeen = new HashSet<>();

        while (!valuesSeen.contains(finalValue)) {
            valuesSeen.add(finalValue);
            value = initialValue;
            value = (value * 4 + value) & 0xFFFF;
            value = ((value & 0xFF) << 8) | ((value >> 8) & 0xFF);  // XBA
            finalValue = (value & 0xFF) * 0x100;
            finalValue += ((value & 0xFF) + (initialValue & 0xFF) & 0xFF);
            initialValue = finalValue;
        }

        return valuesSeen.size();
    }

//            // Perform the operations as per the assembly code
//            value = (value * 4 + value) & 0xFFFF;  // ASL A twice, then ADC $00D6
//            value = ((value & 0xFF) << 8) | ((value >> 8) & 0xFF);  // XBA
//            value = (value + (initialValue & 0xFF)) & 0xFFFF;  // ADC $00D6 again
}
