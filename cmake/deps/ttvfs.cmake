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
    MESSAGE("-- Using external binaries ttvfs")

    ADD_CUSTOM_TARGET(ttvfs-ex)

    SET(INSTALL_DIR "${CMAKE_SOURCE_DIR}/binaries/ttvfs")

    SET(TTVFS_INCLUDE_DIRS "${INSTALL_DIR}/include")

    ADD_LIBRARY(ttvfs STATIC IMPORTED)

    IF(WIN32)
        SET_TARGET_PROPERTIES(ttvfs PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfsd${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(ttvfs PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(ttvfs PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

    ADD_LIBRARY(ttvfs_cfileapi STATIC IMPORTED)

    IF(WIN32)
        SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapid${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

    ADD_LIBRARY(ttvfs_zip STATIC IMPORTED)

    IF(WIN32)
        SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zipd${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

    SET(TTVFS_GEN_PATH "${INSTALL_DIR}/bin/ttvfs_gen")
ELSE(USE_EXTERNAL_BINARIES)
    MESSAGE("-- Building external ttvfs")

    IF(EXISTS "${CMAKE_SOURCE_DIR}/deps/ttvfs.zip")
        SET(TTVFS_URL
            URL "${CMAKE_SOURCE_DIR}/deps/ttvfs.zip"
        )
    ELSEIF(GIT_DEPENDENCIES)
        SET(TTVFS_URL
            GIT_REPOSITORY https://github.com/comphack/ttvfs.git
            GIT_TAG comp_hack
        )
    ELSE()
        SET(TTVFS_URL
            URL https://github.com/comphack/ttvfs/archive/comp_hack-20180424.zip
            URL_HASH SHA1=c3feca3b35109e9ad4ae61821f62df76a412b87f
        )
    ENDIF()

    ExternalProject_Add(
        ttvfs-ex

        ${TTVFS_URL}

        PREFIX ${CMAKE_CURRENT_BINARY_DIR}/ttvfs
        CMAKE_ARGS ${CMAKE_RELWITHDEBINFO_OPTIONS} -DCMAKE_INSTALL_PREFIX:PATH=<INSTALL_DIR> "-DCMAKE_CXX_FLAGS=-std=c++11 ${SPECIAL_COMPILER_FLAGS}" -DUSE_STATIC_RUNTIME=${USE_STATIC_RUNTIME} -DCMAKE_DEBUG_POSTFIX=d

        # Dump output to a log instead of the screen.
        LOG_DOWNLOAD ON
        LOG_CONFIGURE ON
        LOG_BUILD ON
        LOG_INSTALL ON

        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}

        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfsd${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapid${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zipd${CMAKE_STATIC_LIBRARY_SUFFIX}

        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
        BUILD_BYPRODUCTS <INSTALL_DIR>/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}
    )

    ExternalProject_Get_Property(ttvfs-ex INSTALL_DIR)

    SET_TARGET_PROPERTIES(ttvfs-ex PROPERTIES FOLDER "Dependencies")

    SET(TTVFS_INCLUDE_DIRS "${INSTALL_DIR}/include")

    FILE(MAKE_DIRECTORY "${TTVFS_INCLUDE_DIRS}")

    ADD_LIBRARY(ttvfs STATIC IMPORTED)
    ADD_DEPENDENCIES(ttvfs ttvfs-ex)

    IF(WIN32)
        SET_TARGET_PROPERTIES(ttvfs PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfsd${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(ttvfs PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(ttvfs PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

    ADD_LIBRARY(ttvfs_cfileapi STATIC IMPORTED)
    ADD_DEPENDENCIES(ttvfs_cfileapi ttvfs-ex)

    IF(WIN32)
        SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapid${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_cfileapi${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(ttvfs_cfileapi PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

    ADD_LIBRARY(ttvfs_zip STATIC IMPORTED)
    ADD_DEPENDENCIES(ttvfs_zip ttvfs-ex)

    IF(WIN32)
        SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES
            IMPORTED_LOCATION_RELEASE "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_RELWITHDEBINFO "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip_reldeb${CMAKE_STATIC_LIBRARY_SUFFIX}"
            IMPORTED_LOCATION_DEBUG "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zipd${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ELSE()
        SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES IMPORTED_LOCATION
            "${INSTALL_DIR}/lib/${CMAKE_STATIC_LIBRARY_PREFIX}ttvfs_zip${CMAKE_STATIC_LIBRARY_SUFFIX}")
    ENDIF()

    SET_TARGET_PROPERTIES(ttvfs_zip PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${TTVFS_INCLUDE_DIRS}")

    SET(TTVFS_GEN_PATH "${INSTALL_DIR}/bin/ttvfs_gen")
ENDIF(USE_EXTERNAL_BINARIES)
