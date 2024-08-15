import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class Main {

    public static void main(String[] args) {
        int initialValue = 0x1E37;
        int period = calculatePeriod(initialValue);
        System.out.println("Period: " + period);
    }

    //Generates pseudo random numbers based on the BoF2 RNG
    //This generator has a period of 57973, the average distribution, by 1000's, is 875
    //This also appears to be roughly evenly distributed among all the range of 0 to 65535
    //The only issue is, for good reasons, the numbers above 65000 happen less consistently than other values
    public static int calculatePeriod(int initialValue) {
        int value;
        int finalValue = initialValue;
        Set<Integer> valuesSeen = new HashSet<>();
        HashMap<Integer, Integer> distributionSet = new HashMap<>();
        int averageDistribution;

        while (!valuesSeen.contains(finalValue)) {
            valuesSeen.add(finalValue);
            value = initialValue;
            value = (value * 4 + value) & 0xFFFF;
            value = ((value & 0xFF) << 8) | ((value >> 8) & 0xFF);
            finalValue = (value & 0xFF) * 0x100;
            finalValue += ((value & 0xFF) + (initialValue & 0xFF) & 0xFF);
            initialValue = finalValue;
        }

        valuesSeen.forEach(val -> {
            int key = (int) Math.floor((float) val / 1000);
            distributionSet.put(key, distributionSet.getOrDefault(key, 0) + 1);
        });
        averageDistribution = distributionSet.values().stream().mapToInt(i -> i).sum() / distributionSet.size();
        System.out.println(averageDistribution);
        return valuesSeen.size();
    }
}
