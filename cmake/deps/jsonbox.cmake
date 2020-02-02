# This file is part of COMP_hack.
#
# Copyright (C) 2010-2020 COMP_hack Team <compomega@tutanota.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

IF(USE_EXTERNAL_BINARIES)
    MESSAGE("-- Using external binaries JsonBox")

    ADD_CUSTOM_TARGET(jsonbox-ex)

    SET(INSTALL_DIR "${CMAKE_SOURCE_DIR}/binaries/jsonbox")

    SET(JSONBOX_INCLUDE_DIRS "${INSTALL_DIR}/include")

    ADD_LIBRARY(jsonbox STATIC IMPORTED)

    IF(WIN32)
        SET_TARGET_PROPERTIES(jsonbox PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBoxd${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(jsonbox PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(jsonbox PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${JSONBOX_INCLUDE_DIRS}")
ELSE(USE_EXTERNAL_BINARIES)
    MESSAGE("-- Building external JsonBox")

    IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/JsonBox.zip")
        SET(JSONBOX_URL
            URL "${CMAKE_SOURCE_DIR}/deps/JsonBox.zip"
        )
    ELSEIF(GIT_DEPENDENCIES)
        SET(JSONBOX_URL
            GIT_REPOSITORY https://github.com/comphack/JsonBox.git
            GIT_TAG comp_hack
        )
    ELSE()
        SET(JSONBOX_URL
            URL https://github.com/comphack/JsonBox/archive/comp_hack-20180424.zip
            URL_HASH SHA1=60fce942f5910a6da8db27d4dcb894ea28adea57
        )
    ENDIF()

    ExternalProject_Add(
        jsonbox-ex

        ${JSONBOX_URL}

        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/JsonBox
        CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> -DBUILD_SHARED_LIBS=OFF "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

        # Dump output to a log instead of the screen.
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        LOG_INSTALL ON

        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBoxd${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    )

    ExternalProject_Get_Property(jsonbox-ex INSTALL_DIR)

    SET_TARGET_PROPERTIES(jsonbox-ex PROPERTIES FOLDER "Dependencies")

    SET(JSONBOX_INCLUDE_DIRS "${INSTALL_DIR}/include")

    FILE(MAKE_DIRECTORY "${JSONBOX_INCLUDE_DIRS}")

    ADD_LIBRARY(jsonbox STATIC IMPORTED)
    ADD_DEPENDENCIES(jsonbox jsonbox-ex)

    IF(WIN32)
        SET_TARGET_PROPERTIES(jsonbox PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBoxd${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(jsonbox PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}JsonBox${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(jsonbox PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${JSONBOX_INCLUDE_DIRS}")
ENDIF(USE_EXTERNAL_BINARIES)
