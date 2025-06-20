package com.xiangrecord.controller;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 连续片段识别算法的单元测试
 * 使用main方法进行测试，不依赖外部测试框架
 */
public class ContinuousSegmentTest {

    public static void main(String[] args) {
        System.out.println("开始测试连续片段识别算法...");
        
        // 测试用例1：完全连续的数据
        testCase1();
        
        // 测试用例2：部分连续的数据
        testCase2();
        
        // 测试用例3：完全不连续的数据
        testCase3();
        
        // 测试用例4：单个数据
        testCase4();
        
        // 测试用例5：空数据
        testCase5();
        
        // 测试用例6：复杂的混合场景
        testCase6();
        
        System.out.println("所有测试用例执行完成！");
    }

    /**
     * 测试用例1：完全连续的数据
     * 输入：tsList=[1000, 2000, 3000, 4000, 5000]
     * 数据库中存在：[1000, 2000, 3000, 4000, 5000]
     * 期望：1个连续片段 [1000-5000]
     */
    private static void testCase1() {
        System.out.println("\n=== 测试用例1：完全连续的数据 ===");
        
        List<Long> tsList = Arrays.asList(1000L, 2000L, 3000L, 4000L, 5000L);
        Map<String, String> listRes = new HashMap<>();
        listRes.put("1000", "value1");
        listRes.put("2000", "value2");
        listRes.put("3000", "value3");
        listRes.put("4000", "value4");
        listRes.put("5000", "value5");
        
        List<List<Long>> segments = findContinuousSegments(tsList, listRes);
        
        System.out.println("输入tsList: " + tsList);
        System.out.println("数据库存在的key: " + listRes.keySet());
        System.out.println("识别的连续片段: " + segments);
        
        // 验证结果
        assert segments.size() == 1 : "应该有1个连续片段";
        assert segments.get(0).equals(Arrays.asList(1000L, 2000L, 3000L, 4000L, 5000L)) : "片段内容不正确";
        
        System.out.println("✓ 测试通过");
    }

    /**
     * 测试用例2：部分连续的数据
     * 输入：tsList=[1000, 2000, 3000, 5000, 6000, 8000]
     * 数据库中存在：[1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000]
     * 期望：3个连续片段 [1000-3000], [5000-6000], [8000]
     */
    private static void testCase2() {
        System.out.println("\n=== 测试用例2：部分连续的数据 ===");
        
        List<Long> tsList = Arrays.asList(1000L, 2000L, 3000L, 5000L, 6000L, 8000L);
        Map<String, String> listRes = new HashMap<>();
        listRes.put("1000", "value1");
        listRes.put("2000", "value2");
        listRes.put("3000", "value3");
        listRes.put("4000", "value4"); // 不在删除列表中
        listRes.put("5000", "value5");
        listRes.put("6000", "value6");
        listRes.put("7000", "value7"); // 不在删除列表中
        listRes.put("8000", "value8");
        
        List<List<Long>> segments = findContinuousSegments(tsList, listRes);
        
        System.out.println("输入tsList: " + tsList);
        System.out.println("数据库存在的key: " + listRes.keySet());
        System.out.println("识别的连续片段: " + segments);
        
        // 验证结果
        assert segments.size() == 3 : "应该有3个连续片段";
        assert segments.get(0).equals(Arrays.asList(1000L, 2000L, 3000L)) : "第1个片段不正确";
        assert segments.get(1).equals(Arrays.asList(5000L, 6000L)) : "第2个片段不正确";
        assert segments.get(2).equals(Arrays.asList(8000L)) : "第3个片段不正确";
        
        System.out.println("✓ 测试通过");
    }

    /**
     * 测试用例3：完全不连续的数据
     * 输入：tsList=[1000, 3000, 5000]
     * 数据库中存在：[1000, 2000, 3000, 4000, 5000]
     * 期望：3个连续片段 [1000], [3000], [5000]
     */
    private static void testCase3() {
        System.out.println("\n=== 测试用例3：完全不连续的数据 ===");
        
        List<Long> tsList = Arrays.asList(1000L, 3000L, 5000L);
        Map<String, String> listRes = new HashMap<>();
        listRes.put("1000", "value1");
        listRes.put("2000", "value2"); // 不在删除列表中
        listRes.put("3000", "value3");
        listRes.put("4000", "value4"); // 不在删除列表中
        listRes.put("5000", "value5");
        
        List<List<Long>> segments = findContinuousSegments(tsList, listRes);
        
        System.out.println("输入tsList: " + tsList);
        System.out.println("数据库存在的key: " + listRes.keySet());
        System.out.println("识别的连续片段: " + segments);
        
        // 验证结果
        assert segments.size() == 3 : "应该有3个连续片段";
        assert segments.get(0).equals(Arrays.asList(1000L)) : "第1个片段不正确";
        assert segments.get(1).equals(Arrays.asList(3000L)) : "第2个片段不正确";
        assert segments.get(2).equals(Arrays.asList(5000L)) : "第3个片段不正确";
        
        System.out.println("✓ 测试通过");
    }

    /**
     * 测试用例4：单个数据
     * 输入：tsList=[1000]
     * 数据库中存在：[1000]
     * 期望：1个连续片段 [1000]
     */
    private static void testCase4() {
        System.out.println("\n=== 测试用例4：单个数据 ===");
        
        List<Long> tsList = Arrays.asList(1000L);
        Map<String, String> listRes = new HashMap<>();
        listRes.put("1000", "value1");
        
        List<List<Long>> segments = findContinuousSegments(tsList, listRes);
        
        System.out.println("输入tsList: " + tsList);
        System.out.println("数据库存在的key: " + listRes.keySet());
        System.out.println("识别的连续片段: " + segments);
        
        // 验证结果
        assert segments.size() == 1 : "应该有1个连续片段";
        assert segments.get(0).equals(Arrays.asList(1000L)) : "片段内容不正确";
        
        System.out.println("✓ 测试通过");
    }

    /**
     * 测试用例5：空数据
     * 输入：tsList=[1000, 2000]
     * 数据库中存在：[]
     * 期望：0个连续片段
     */
    private static void testCase5() {
        System.out.println("\n=== 测试用例5：空数据 ===");
        
        List<Long> tsList = Arrays.asList(1000L, 2000L);
        Map<String, String> listRes = new HashMap<>();
        
        List<List<Long>> segments = findContinuousSegments(tsList, listRes);
        
        System.out.println("输入tsList: " + tsList);
        System.out.println("数据库存在的key: " + listRes.keySet());
        System.out.println("识别的连续片段: " + segments);
        
        // 验证结果
        assert segments.size() == 0 : "应该有0个连续片段";
        
        System.out.println("✓ 测试通过");
    }

    /**
     * 测试用例6：复杂的混合场景
     * 输入：tsList=[1000, 2000, 4000, 5000, 6000, 9000, 10000, 11000, 15000]
     * 数据库中存在：[1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000, 11000, 12000, 13000, 14000, 15000]
     * 期望：4个连续片段 [1000-2000], [4000-6000], [9000-11000], [15000]
     */
    private static void testCase6() {
        System.out.println("\n=== 测试用例6：复杂的混合场景 ===");
        
        List<Long> tsList = Arrays.asList(1000L, 2000L, 4000L, 5000L, 6000L, 9000L, 10000L, 11000L, 15000L);
        Map<String, String> listRes = new HashMap<>();
        for (long i = 1000; i <= 15000; i += 1000) {
            listRes.put(String.valueOf(i), "value" + i);
        }
        
        List<List<Long>> segments = findContinuousSegments(tsList, listRes);
        
        System.out.println("输入tsList: " + tsList);
        System.out.println("数据库存在的key: " + listRes.keySet());
        System.out.println("识别的连续片段: " + segments);
        
        // 验证结果
        assert segments.size() == 4 : "应该有4个连续片段";
        assert segments.get(0).equals(Arrays.asList(1000L, 2000L)) : "第1个片段不正确";
        assert segments.get(1).equals(Arrays.asList(4000L, 5000L, 6000L)) : "第2个片段不正确";
        assert segments.get(2).equals(Arrays.asList(9000L, 10000L, 11000L)) : "第3个片段不正确";
        assert segments.get(3).equals(Arrays.asList(15000L)) : "第4个片段不正确";
        
        System.out.println("✓ 测试通过");
    }

    /**
     * 核心算法：找出tsList在listRes中的连续片段
     * 这是从DelbodydataHandler中提取的核心逻辑
     */
    private static List<List<Long>> findContinuousSegments(List<Long> tsList, Map<String, String> listRes) {
        // 找到所有的listRes的key
        List<String> listResKey = listRes.keySet().stream().collect(Collectors.toList());
        
        // 将listResKey转换为Long类型的时间戳列表，并排序
        List<Long> existingTsList = listResKey.stream()
                .map(Long::valueOf)
                .sorted()
                .collect(Collectors.toList());
        
        // 找出tsList中在existingTsList中存在的时间戳，并按顺序排列
        List<Long> validTsList = tsList.stream()
                .filter(ts -> existingTsList.contains(ts))
                .sorted()
                .collect(Collectors.toList());
        
        // 将validTsList分割成连续的片段
        List<List<Long>> continuousSegments = new ArrayList<>();
        if (!validTsList.isEmpty()) {
            List<Long> currentSegment = new ArrayList<>();
            currentSegment.add(validTsList.get(0));
            
            for (int i = 1; i < validTsList.size(); i++) {
                Long currentTs = validTsList.get(i);
                Long previousTs = validTsList.get(i - 1);
                
                // 检查当前时间戳在existingTsList中是否与前一个时间戳连续
                int currentIndex = existingTsList.indexOf(currentTs);
                int previousIndex = existingTsList.indexOf(previousTs);
                
                if (currentIndex == previousIndex + 1) {
                    // 连续，添加到当前片段
                    currentSegment.add(currentTs);
                } else {
                    // 不连续，保存当前片段并开始新片段
                    continuousSegments.add(new ArrayList<>(currentSegment));
                    currentSegment.clear();
                    currentSegment.add(currentTs);
                }
            }
            // 添加最后一个片段
            continuousSegments.add(currentSegment);
        }
        
        return continuousSegments;
    }
}