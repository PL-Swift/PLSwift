//
//  PGExtension.swift
//  PL/Swift
//
//  Created by Helge Hess on 05.01.18.
//  Copyright © 2018-2019 ZeeZide GmbH. All rights reserved.
//

import CPLSwift


// MARK: - PG_MAGIC_BLOCK

public let PG_MAGIC_FUNCTION_NAME_STRING = "Pg_magic_func"

fileprivate var PGExtensionMagicStructValue = Pg_magic_struct(
  len          : Int32(MemoryLayout<Pg_magic_struct>.stride),
  version      : PG_VERSION_NUM / 100,
  funcmaxargs  : FUNC_MAX_ARGS,
  indexmaxkeys : INDEX_MAX_KEYS,
  namedatalen  : NAMEDATALEN,
  float4byval  : FLOAT4PASSBYVAL != 0 ? 1 : 0,
  float8byval  : FLOAT8PASSBYVAL != 0 ? 1 : 0
)

public let PGExtensionMagicStruct =
      UnsafeRawPointer(UnsafeMutablePointer(&PGExtensionMagicStructValue))


// MARK: - PG_FUNCTION_INFO_V1

fileprivate var PG_FUNCTION_INFO_V1_value = Pg_finfo_record(api_version: 1)
public let PG_FUNCTION_INFO_V1 =
      UnsafeRawPointer(UnsafeMutablePointer(&PG_FUNCTION_INFO_V1_value))
