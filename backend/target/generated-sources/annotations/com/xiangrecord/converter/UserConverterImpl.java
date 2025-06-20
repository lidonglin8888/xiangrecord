package com.xiangrecord.converter;

import com.xiangrecord.dto.UserDTO;
import com.xiangrecord.entity.User;
import javax.annotation.processing.Generated;
import org.springframework.stereotype.Component;

@Generated(
    value = "org.mapstruct.ap.MappingProcessor",
    date = "2025-06-20T11:01:45+0800",
    comments = "version: 1.5.5.Final, compiler: javac, environment: Java 21.0.5 (Microsoft)"
)
@Component
public class UserConverterImpl implements UserConverter {

    @Override
    public UserDTO toDTO(User user) {
        if ( user == null ) {
            return null;
        }

        UserDTO.UserDTOBuilder userDTO = UserDTO.builder();

        userDTO.id( user.getId() );
        userDTO.username( user.getUsername() );
        userDTO.email( user.getEmail() );
        userDTO.phone( user.getPhone() );
        userDTO.avatar( user.getAvatar() );
        userDTO.loginType( user.getLoginType() );
        userDTO.huaweiId( user.getHuaweiId() );
        userDTO.wechatId( user.getWechatId() );
        userDTO.lastLoginTime( user.getLastLoginTime() );
        userDTO.isActive( user.getIsActive() );

        return userDTO.build();
    }

    @Override
    public User toEntity(UserDTO userDTO) {
        if ( userDTO == null ) {
            return null;
        }

        User.UserBuilder user = User.builder();

        user.username( userDTO.getUsername() );
        user.email( userDTO.getEmail() );
        user.phone( userDTO.getPhone() );
        user.avatar( userDTO.getAvatar() );
        user.loginType( userDTO.getLoginType() );
        user.huaweiId( userDTO.getHuaweiId() );
        user.wechatId( userDTO.getWechatId() );
        user.lastLoginTime( userDTO.getLastLoginTime() );
        user.isActive( userDTO.getIsActive() );

        return user.build();
    }

    @Override
    public UserDTO toSafeDTO(User user) {
        if ( user == null ) {
            return null;
        }

        UserDTO.UserDTOBuilder userDTO = UserDTO.builder();

        userDTO.id( user.getId() );
        userDTO.username( user.getUsername() );
        userDTO.email( user.getEmail() );
        userDTO.phone( user.getPhone() );
        userDTO.avatar( user.getAvatar() );
        userDTO.loginType( user.getLoginType() );
        userDTO.lastLoginTime( user.getLastLoginTime() );
        userDTO.isActive( user.getIsActive() );

        return userDTO.build();
    }
}
