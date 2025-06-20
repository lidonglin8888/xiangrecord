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
                return ResponseEntity.ok(ApiResponse.success("记录删除成功"));
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
    @Operation(summary = "分页查询记录", description = "分页查询便便记录，支持多种条件过滤")
    public ResponseEntity<ApiResponse<IPage<PoopRecordDTO>>> getRecords(
            @Parameter(description = "页码，从1开始") @RequestParam(defaultValue = "1") @Min(1) Integer page,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "10") @Min(1) @Max(100) Integer size,
            @Parameter(description = "颜色过滤") @RequestParam(required = false) String color,
            @Parameter(description = "气味过滤") @RequestParam(required = false) String smell,
            @Parameter(description = "干湿度过滤") @RequestParam(required = false) String moisture,
            @Parameter(description = "形状过滤") @RequestParam(required = false) String shape,
            @Parameter(description = "大小过滤") @RequestParam(required = false) String size_filter,
            @Parameter(description = "质地过滤") @RequestParam(required = false) String texture,
            @Parameter(description = "心情过滤") @RequestParam(required = false) String mood,
            @Parameter(description = "开始时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "结束时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime,
            @Parameter(description = "排序字段") @RequestParam(defaultValue = "recordTime") String sortBy,
            @Parameter(description = "排序方向") @RequestParam(defaultValue = "desc") String sortDirection) {
        try {
            Page<PoopRecordDTO> pageRequest = new Page<>(page, size);
            
            // 添加排序
            if ("asc".equalsIgnoreCase(sortDirection)) {
                pageRequest.addOrder(OrderItem.asc(sortBy));
            } else {
                pageRequest.addOrder(OrderItem.desc(sortBy));
            }
            
            IPage<PoopRecordDTO> records = poopRecordService.getRecords(
                    pageRequest, color, smell, moisture, shape, size_filter, texture, mood, startTime, endTime);
            
            return ResponseEntity.ok(ApiResponse.success("查询成功", records));
        } catch (Exception e) {
            log.error("查询记录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "查询记录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/today")
    @Operation(summary = "获取今日记录", description = "获取今天的所有便便记录")
    public ResponseEntity<ApiResponse<List<PoopRecordDTO>>> getTodayRecords() {
        try {
            List<PoopRecordDTO> records = poopRecordService.getTodayRecords();
            return ResponseEntity.ok(ApiResponse.success("获取今日记录成功", records));
        } catch (Exception e) {
            log.error("获取今日记录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "获取今日记录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/recent")
    @Operation(summary = "获取最近记录", description = "获取最近的便便记录")
    public ResponseEntity<ApiResponse<List<PoopRecordDTO>>> getRecentRecords(
            @Parameter(description = "记录数量") @RequestParam(defaultValue = "10") @Min(1) @Max(50) Integer limit) {
        try {
            List<PoopRecordDTO> records = poopRecordService.getRecentRecords(limit);
            return ResponseEntity.ok(ApiResponse.success("获取最近记录成功", records));
        } catch (Exception e) {
            log.error("获取最近记录失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "获取最近记录失败: " + e.getMessage()));
        }
    }

    @GetMapping("/stats")
    @Operation(summary = "获取统计数据", description = "获取便便记录的统计信息")
    public ResponseEntity<ApiResponse<Object>> getStats(
            @Parameter(description = "统计开始时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startTime,
            @Parameter(description = "统计结束时间") @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endTime) {
        try {
            Object stats = poopRecordService.getStats(startTime, endTime);
            return ResponseEntity.ok(ApiResponse.success("获取统计数据成功", stats));
        } catch (Exception e) {
            log.error("获取统计数据失败", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error(500, "获取统计数据失败: " + e.getMessage()));
        }
    }
}