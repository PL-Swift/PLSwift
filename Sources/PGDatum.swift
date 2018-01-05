//
//  PGDatum.swift
//  PL/Swift
//
//  Created by Helge Hess on 05.01.18.
//  Copyright © 2018 ZeeZide GmbH. All rights reserved.
//

import CPLSwift

/*
#define PG_RETURN_TEXT_P(x)    PG_RETURN_POINTER(x)

#define PG_RETURN_POINTER(x) return PointerGetDatum(x) // does a RETURN
#define PointerGetDatum(X)   ((Datum) (X)) // cast pointer to datum
*/

public func PointerGetDatum(_ ptr: UnsafeRawPointer?) -> Datum {
  guard let ptr = ptr else { return 0 }
  return Datum(bitPattern: ptr)
}

public let PG_RETURN_POINTER = PointerGetDatum
public let PG_RETURN_TEXT_P  = PG_RETURN_POINTER


public extension Datum {
  
  public var int64Value : Int64 {
    /*
     #define DatumGetInt32(X) ((int32) GET_4_BYTES(X))
     #define GET_4_BYTES(datum)  (((Datum) (datum)) & 0xffffffff)
     */
    return Int64(bitPattern: UInt64(self))
  }
  
  public var intValue : Int {
    return Int(int64Value)
  }
}

public protocol PGDatumRepresentable {
  var pgDatum : Datum { get }
}

extension String : PGDatumRepresentable {
  public var pgDatum : Datum {
    // UnsafeMutablePointer<text>?
    let txt = cstring_to_text(self)
    
    // cast to Datum
    return PG_RETURN_TEXT_P(txt)
  }
}

extension Int64 : PGDatumRepresentable {
  
  public var pgDatum : Datum {
    if USE_FLOAT8_BYVAL != 0 { return Datum(UInt64(bitPattern: self)) }
    else                     { fatalError("not supported") }
  }
  
}

extension Int : PGDatumRepresentable {
  
  public var pgDatum : Datum {
    // TODO: check size and distinguish between 32&64 bit
    return Int64(self).pgDatum
  }
  
}
