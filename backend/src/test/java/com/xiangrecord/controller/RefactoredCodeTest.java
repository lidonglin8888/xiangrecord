package com.xiangrecord.controller;

import java.util.*;
import java.util.stream.Collectors;

/**
 * 重构后代码的测试类
 * 测试L90-106代码段及相关子方法的正确性
 * 使用main方法进行测试，不依赖外部测试框架
 */
public class RefactoredCodeTest {

    public static void main(String[] args) {
        System.out.println("开始测试重构后的代码逻辑...");
        
        // 测试时间戳范围计算
        testTimestampRangeCalculation();
        
        // 测试数据完整性判断逻辑
        testDataIntegrityLogic();
        
        // 测试连续片段识别算法
        testContinuousSegmentAlgorithm();
        
        // 测试分段处理逻辑
        testSegmentProcessing();
        
        // 测试连续性检查
        testConsecutiveCheck();
        
        // 测试边界情况
        testEdgeCases();
        
        System.out.println("所有测试用例执行完成！");
    }

    /**
     * 测试时间戳范围计算（模拟L90-94的逻辑）
     */
    private static void testTimestampRangeCalculation() {
        System.out.println("\n=== 测试时间戳范围计算 ===");
        
        // 测试用例1：正常情况
        List<Long> tsList1 = Arrays.asList(1000L, 3000L, 2000L, 5000L, 4000L);
        LongSummaryStatistics stats1 = tsList1.stream().mapToLong(Long::longValue).summaryStatistics();
        System.out.println("输入: " + tsList1);
        System.out.println("最小值: " + stats1.getMin() + ", 最大值: " + stats1.getMax());
        assert stats1.getMin() == 1000L : "最小值计算错误";
        assert stats1.getMax() == 5000L : "最大值计算错误";
        
        // 测试用例2：单个元素
        List<Long> tsList2 = Arrays.asList(2000L);
        LongSummaryStatistics stats2 = tsList2.stream().mapToLong(Long::longValue).summaryStatistics();
        System.out.println("单个元素输入: " + tsList2);
        System.out.println("最小值: " + stats2.getMin() + ", 最大值: " + stats2.getMax());
        assert stats2.getMin() == 2000L : "单个元素最小值错误";
        assert stats2.getMax() == 2000L : "单个元素最大值错误";
        
        System.out.println("✓ 时间戳范围计算测试通过");
    }

    /**
     * 测试数据完整性判断逻辑（模拟L100-106的逻辑）
     */
    private static void testDataIntegrityLogic() {
        System.out.println("\n=== 测试数据完整性判断逻辑 ===");
        
        // 测试用例1：数据完整
        List<Long> tsList1 = Arrays.asList(1000L, 2000L, 3000L);
        Map<String, String> listRes1 = new HashMap<>();
        listRes1.put("1000", "value1");
        listRes1.put("2000", "value2");
        listRes1.put("3000", "value3");
        
        boolean isComplete1 = listRes1.size() == tsList1.size();
        System.out.println("tsList大小: " + tsList1.size() + ", listRes大小: " + listRes1.size());
        System.out.println("数据完整性: " + (isComplete1 ? "完整" : "不完整"));
        assert isComplete1 : "应该判断为数据完整";
        
        // 测试用例2：数据不完整
        List<Long> tsList2 = Arrays.asList(1000L, 2000L, 3000L, 4000L);
        Map<String, String> listRes2 = new HashMap<>();
        listRes2.put("1000", "value1");
        listRes2.put("2000", "value2");
        listRes2.put("3000", "value3");
        
        boolean isComplete2 = listRes2.size() == tsList2.size();
        System.out.println("tsList大小: " + tsList2.size() + ", listRes大小: " + listRes2.size());
        System.out.println("数据完整性: " + (isComplete2 ? "完整" : "不完整"));
        assert !isComplete2 : "应该判断为数据不完整";
        
        System.out.println("✓ 数据完整性判断测试通过");
    }

    /**
     * 测试连续片段识别算法
     */
    private static void testContinuousSegmentAlgorithm() {
        System.out.println("\n=== 测试连续片段识别算法 ===");
        
        // 测试用例1：完全连续
        List<Long> tsList1 = Arrays.asList(1000L, 2000L, 3000L);
        Map<String, String> listRes1 = new HashMap<>();
        listRes1.put("1000", "value1");
        listRes1.put("2000", "value2");
        listRes1.put("3000", "value3");
        
        List<List<Long>> segments1 = findContinuousSegments(tsList1, listRes1);
        System.out.println("完全连续测试 - 输入: " + tsList1);
        System.out.println("识别的片段: " + segments1);
        assert segments1.size() == 1 : "应该有1个连续片段";
        assert segments1.get(0).size() == 3 : "片段应包含3个元素";
        
        // 测试用例2：部分连续
        List<Long> tsList2 = Arrays.asList(1000L, 2000L, 4000L, 5000L);
        Map<String, String> listRes2 = new HashMap<>();
        listRes2.put("1000", "value1");
        listRes2.put("2000", "value2");
        listRes2.put("3000", "value3"); // 不在删除列表中
        listRes2.put("4000", "value4");
        listRes2.put("5000", "value5");
        
        List<List<Long>> segments2 = findContinuousSegments(tsList2, listRes2);
        System.out.println("部分连续测试 - 输入: " + tsList2);
        System.out.println("识别的片段: " + segments2);
        assert segments2.size() == 2 : "应该有2个连续片段";
        
        System.out.println("✓ 连续片段识别算法测试通过");
    }

    /**
     * 测试分段处理逻辑
     */
    private static void testSegmentProcessing() {
        System.out.println("\n=== 测试分段处理逻辑 ===");
        
        List<Long> validTsList = Arrays.asList(1000L, 2000L, 4000L, 5000L, 6000L);
        List<Long> existingTsList = Arrays.asList(1000L, 2000L, 3000L, 4000L, 5000L, 6000L);
        
        List<List<Long>> segments = segmentTimestamps(validTsList, existingTsList);
        System.out.println("有效时间戳: " + validTsList);
        System.out.println("存在的时间戳: " + existingTsList);
        System.out.println("分段结果: " + segments);
        
        assert segments.size() == 2 : "应该分成2个片段";
        assert segments.get(0).equals(Arrays.asList(1000L, 2000L)) : "第1个片段不正确";
        assert segments.get(1).equals(Arrays.asList(4000L, 5000L, 6000L)) : "第2个片段不正确";
        
        System.out.println("✓ 分段处理逻辑测试通过");
    }

    /**
     * 测试连续性检查
     */
    private static void testConsecutiveCheck() {
        System.out.println("\n=== 测试连续性检查 ===");
        
        List<Long> existingTsList = Arrays.asList(1000L, 2000L, 3000L, 5000L, 6000L);
        
        // 测试连续的情况
        boolean consecutive1 = isConsecutive(2000L, 1000L, existingTsList);
        System.out.println("2000L和1000L是否连续: " + consecutive1);
        assert consecutive1 : "2000L和1000L应该是连续的";
        
        // 测试不连续的情况
        boolean consecutive2 = isConsecutive(5000L, 3000L, existingTsList);
        System.out.println("5000L和3000L是否连续: " + consecutive2);
        assert !consecutive2 : "5000L和3000L应该是不连续的";
        
        // 测试边界情况
        boolean consecutive3 = isConsecutive(6000L, 5000L, existingTsList);
        System.out.println("6000L和5000L是否连续: " + consecutive3);
        assert consecutive3 : "6000L和5000L应该是连续的";
        
        System.out.println("✓ 连续性检查测试通过");
    }

    /**
     * 测试边界情况
     */
    private static void testEdgeCases() {
        System.out.println("\n=== 测试边界情况 ===");
        
        // 测试空列表
        List<Long> emptyList = new ArrayList<>();
        Map<String, String> emptyMap = new HashMap<>();
        List<List<Long>> emptySegments = findContinuousSegments(emptyList, emptyMap);
        System.out.println("空列表测试结果: " + emptySegments);
        assert emptySegments.isEmpty() : "空列表应该返回空片段";
        
        // 测试单个元素
        List<Long> singleList = Arrays.asList(1000L);
        Map<String, String> singleMap = new HashMap<>();
        singleMap.put("1000", "value1");
        List<List<Long>> singleSegments = findContinuousSegments(singleList, singleMap);
        System.out.println("单个元素测试结果: " + singleSegments);
        assert singleSegments.size() == 1 : "单个元素应该返回1个片段";
        assert singleSegments.get(0).size() == 1 : "片段应包含1个元素";
        
        // 测试无匹配数据
        List<Long> noMatchList = Arrays.asList(1000L, 2000L);
        Map<String, String> noMatchMap = new HashMap<>();
        noMatchMap.put("3000", "value3");
        noMatchMap.put("4000", "value4");
        List<List<Long>> noMatchSegments = findContinuousSegments(noMatchList, noMatchMap);
        System.out.println("无匹配数据测试结果: " + noMatchSegments);
        assert noMatchSegments.isEmpty() : "无匹配数据应该返回空片段";
        
        System.out.println("✓ 边界情况测试通过");
    }

    // ========== 以下是从DelbodydataHandler中提取的核心方法 ==========

    /**
     * 找出tsList在数据库中的连续片段
     */
    private static List<List<Long>> findContinuousSegments(List<Long> tsList, Map<String, String> listRes) {
        // 获取数据库中存在的时间戳并排序
        List<Long> existingTsList = listRes.keySet().stream()
                .map(Long::valueOf)
                .sorted()
                .collect(Collectors.toList());
        
        // 过滤出有效的时间戳并排序
        List<Long> validTsList = tsList.stream()
                .filter(existingTsList::contains)
                .sorted()
                .collect(Collectors.toList());
        
        return segmentTimestamps(validTsList, existingTsList);
    }

    /**
     * 将时间戳列表按连续性分段
     */
    private static List<List<Long>> segmentTimestamps(List<Long> validTsList, List<Long> existingTsList) {
        List<List<Long>> segments = new ArrayList<>();
        if (validTsList.isEmpty()) {
            return segments;
        }
        
        List<Long> currentSegment = new ArrayList<>();
        currentSegment.add(validTsList.get(0));
        
        for (int i = 1; i < validTsList.size(); i++) {
            Long currentTs = validTsList.get(i);
            Long previousTs = validTsList.get(i - 1);
            
            // 检查是否连续
            if (isConsecutive(currentTs, previousTs, existingTsList)) {
                currentSegment.add(currentTs);
            } else {
                segments.add(new ArrayList<>(currentSegment));
                currentSegment.clear();
                currentSegment.add(currentTs);
            }
        }
        segments.add(currentSegment);
        return segments;
    }

    /**
     * 检查两个时间戳在存在列表中是否连续
     */
    private static boolean isConsecutive(Long current, Long previous, List<Long> existingTsList) {
        int currentIndex = existingTsList.indexOf(current);
        int previousIndex = existingTsList.indexOf(previous);
        return currentIndex == previousIndex + 1;
    }
}