package com.xiangrecord.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.xiangrecord.entity.PoopRecord;
import org.apache.ibatis.annotations.Mapper;

/**
 * 便便记录Mapper接口
 * 使用MyBatis Plus的Lambda表达式，无需手写SQL
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Mapper
public interface PoopRecordMapper extends BaseMapper<PoopRecord> {
    // 继承BaseMapper即可，所有CRUD操作通过Service层的Lambda表达式实现
}