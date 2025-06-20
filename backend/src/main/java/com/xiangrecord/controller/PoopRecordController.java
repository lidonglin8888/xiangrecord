package com.xiangrecord.controller;

import com.xiangrecord.dto.ApiResponse;
import com.xiangrecord.dto.PoopRecordDTO;
import com.xiangrecord.service.PoopRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.core.metadata.OrderItem;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * 便便记录控制器
 *
 * @author xiangrecord
 * @version 1.0.0
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/records")
@RequiredArgsConstructor
@Validated
@Tag(name = "便便记录管理", description = "便便记录的增删改查接口")
@CrossOrigin(origins = "*", maxAge = 3600)
public class PoopRecordController {

    private final PoopRecordService poopRecordService;

    @PostMapping
    @Operation(summary = "创建记录", description = "创建一条新的便便记录")
    public ResponseEntity<ApiResponse<PoopRecordDTO>> createRecord(
            @Valid @RequestBody PoopRecordDTO recordDTO) {
        try {
            PoopRecordDTO createdRecord = poopRecordService.createRecord(recordDTO);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.success("记录创建成功", createdRecord));
        } catch (Exception e) {
            log.error("创建记录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "创建记录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取记录", description = "根据ID获取便便记录")
    public ResponseEntity<ApiResponse<PoopRecordDTO>> getRecord(
            @Parameter(description = "记录ID") @PathVariable Long id) {
        try {
            Optional<PoopRecordDTO> record = poopRecordService.getRecordById(id);
            if (record.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success("获取记录成功", record.get()));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(404, "记录不存在"));
            }
        } catch (Exception e) {
            log.error("获取记录失败，ID: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "获取记录失败: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新记录", description = "根据ID更新便便记录")
    public ResponseEntity<ApiResponse<PoopRecordDTO>> updateRecord(
            @Parameter(description = "记录ID") @PathVariable Long id,
            @Valid @RequestBody PoopRecordDTO recordDTO) {
        try {
            Optional<PoopRecordDTO> updatedRecord = poopRecordService.updateRecord(id, recordDTO);
            if (updatedRecord.isPresent()) {
                return ResponseEntity.ok(ApiResponse.success(updatedRecord.get()));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(404, "记录不存在"));
            }
        } catch (Exception e) {
            log.error("更新记录失败，ID: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "更新记录失败: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除记录", description = "根据ID删除便便记录")
    public ResponseEntity<ApiResponse<Void>> deleteRecord(
            @Parameter(description = "记录ID") @PathVariable Long id) {
        try {
            boolean deleted = poopRecordService.deleteRecord(id);
            if (deleted) {
                return ResponseEntity.ok(ApiResponse.success(null));
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND)
                        .body(ApiResponse.error(404, "记录不存在"));
            }
        } catch (Exception e) {
            log.error("删除记录失败，ID: {}", id, e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "删除记录失败: " + e.getMessage()));
        }
    }

    @GetMapping
    @Operation(summary = "分页查询记录", description = "分页查询所有便便记录")
    public ResponseEntity<ApiResponse<IPage<PoopRecordDTO>>> getAllRecords(
            @Parameter(description = "用户ID") @RequestParam(required = false) Long userId,
            @Parameter(description = "页码，从1开始") @RequestParam(defaultValue = "1") @Min(1) int page,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "10") @Min(1) int size,
            @Parameter(description = "排序字段") @RequestParam(defaultValue = "recordTime") String sortBy,
            @Parameter(description = "排序方向") @RequestParam(defaultValue = "desc") String sortDir) {
        try {
            Page<PoopRecordDTO> pageParam = new Page<>(page, size);
            if ("asc".equalsIgnoreCase(sortDir)) {
                pageParam.addOrder(OrderItem.asc(sortBy));
            } else {
                pageParam.addOrder(OrderItem.desc(sortBy));
            }
            IPage<PoopRecordDTO> records = poopRecordService.getAllRecords(pageParam, userId);
            return ResponseEntity.ok(ApiResponse.success(records));
        } catch (Exception e) {
            log.error("查询记录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "查询记录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/search")
    @Operation(summary = "条件查询记录", description = "根据多个条件查询便便记录")
    public ResponseEntity<ApiResponse<IPage<PoopRecordDTO>>> searchRecords(
            @Parameter(description = "用户ID") @RequestParam(required = false) Long userId,
            @Parameter(description = "颜色") @RequestParam(required = false) String color,
            @Parameter(description = "心情") @RequestParam(required = false) String mood,
            @Parameter(description = "开始时间") @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
            @Parameter(description = "页码，从1开始") @RequestParam(defaultValue = "1") @Min(1) int page,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "10") @Min(1) int size) {
        try {
            Page<PoopRecordDTO> pageParam = new Page<>(page, size);

            IPage<PoopRecordDTO> records = poopRecordService.getRecordsByConditions(
                    color, mood, startTime, endTime, pageParam, userId);
            return ResponseEntity.ok(ApiResponse.success(records));
        } catch (Exception e) {
            log.error("条件查询失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "条件查询失败: " + e.getMessage()));
        }
    }

    @GetMapping("/recent")
    @Operation(summary = "获取最近记录", description = "获取最近的便便记录")
    public ResponseEntity<ApiResponse<List<PoopRecordDTO>>> getRecentRecords(
            @Parameter(description = "用户ID") @RequestParam(required = false) Long userId,
            @Parameter(description = "记录数量") @RequestParam(defaultValue = "10") @Min(1) int limit) {
        try {
            List<PoopRecordDTO> records = poopRecordService.getRecentRecords(limit, userId);
            return ResponseEntity.ok(ApiResponse.success(records));
        } catch (Exception e) {
            log.error("获取最近记录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "获取最近记录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/today")
    @Operation(summary = "获取今日记录", description = "获取今天的所有便便记录")
    public ResponseEntity<ApiResponse<List<PoopRecordDTO>>> getTodayRecords(
            @Parameter(description = "用户ID") @RequestParam(required = false) Long userId) {
        try {
            List<PoopRecordDTO> records = poopRecordService.getTodayRecords(userId);
            return ResponseEntity.ok(ApiResponse.success(records));
        } catch (Exception e) {
            log.error("获取今日记录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "获取今日记录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/stats/count")
    @Operation(summary = "统计记录数量", description = "根据条件统计记录数量")
    public ResponseEntity<ApiResponse<Long>> countRecords(
            @Parameter(description = "用户ID") @RequestParam(required = false) Long userId,
            @Parameter(description = "颜色") @RequestParam(required = false) String color,
            @Parameter(description = "心情") @RequestParam(required = false) String mood,
            @Parameter(description = "开始时间") @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam(required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        try {
            long count;

            if (startTime != null && endTime != null) {
                count = poopRecordService.countRecordsByTimeRange(startTime, endTime, userId);
            } else if (color != null) {
                count = poopRecordService.countRecordsByColor(color, userId);
            } else if (mood != null) {
                count = poopRecordService.countRecordsByMood(mood, userId);
            } else {
                // 如果没有条件，统计所有记录
                count = poopRecordService.countRecordsByTimeRange(
                        LocalDateTime.of(1970, 1, 1, 0, 0),
                        LocalDateTime.now(), userId);
            }

            return ResponseEntity.ok(ApiResponse.success(count));
        } catch (Exception e) {
            log.error("统计记录数量失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "统计记录数量失败: " + e.getMessage()));
        }
    }
}