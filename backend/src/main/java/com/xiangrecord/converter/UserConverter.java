package com.xiangrecord.converter;

import com.xiangrecord.dto.UserDTO;
import com.xiangrecord.entity.User;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.factory.Mappers;

/**
 * 用户实体与DTO转换器
 * 
 * @author xiangrecord
 * @version 1.0.0
 */
@Mapper(componentModel = "spring")
public interface UserConverter {

    UserConverter INSTANCE = Mappers.getMapper(UserConverter.class);

    /**
     * 将User实体转换为UserDTO
     * 排除敏感信息如密码哈希
     */
    UserDTO toDTO(User user);

    /**
     * 将UserDTO转换为User实体
     * 用于更新操作时的部分字段转换
     */
    @Mapping(target = "passwordHash", ignore = true)
    @Mapping(target = "isDeleted", ignore = true)
    User toEntity(UserDTO userDTO);

    /**
     * 创建安全的用户DTO，只包含基本信息
     */
    @Mapping(target = "huaweiId", ignore = true)
    @Mapping(target = "wechatId", ignore = true)
    UserDTO toSafeDTO(User user);
}