// !!! THIS CODE IS AUTOMATICALLY GENERATED, DO NOT EDIT BY HAND !!!
//
// Copyright 2018-19 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CTensorFlow

/// **WARNING:** After constructing a `TFE_Op`, any one of its `execute` methods must be called
/// *exactly once*. If not called, then a memory leak is introduced due to the underlying TensorFlow
/// eager op object not being freed. If called more than once, then a SEGFAULT may occur due to
/// trying to execute a TensorFlow eager op that has already been freed.
@usableFromInline
internal struct TFE_Op {
  @usableFromInline internal let status: CTFStatus
  @usableFromInline internal let op: CTFEOp
  // @usableFromInline internal let operands: [(_AnyTensorHandle, CTensorHandle?)]
  @usableFromInline internal var operands: [(_AnyTensorHandle, TF_Output, CTensorHandle?)]
  @usableFromInline internal var graphOp: TF_Output?
  @usableFromInline internal static var placeHolderIndex: Int = 0
  @usableFromInline internal static var traceGraphFunctionCounter: Int = 0
  /// The `TF_OperationDescription *` type.
  @usableFromInline typealias CTFOperation = OpaquePointer

  @usableFromInline
  internal init(_ name: String) {
    self.status = TF_NewStatus()
    self.op = TFE_NewOp(_ExecutionContext.global.eagerContext, name, status)
    self.graphOp = nil
    self.operands = []
  }

  @inlinable @inline(__always)
  internal mutating func addInput(_ inputHandle: _AnyTensorHandle) -> Int {
    print("Adding input")
    let graph = _ExecutionContext.global.traceContext.graph
    switch (inputHandle.lazyHandle) {
    case LazyTensorHandle.conc(let h): do {
        print("Adding my placeholder..")
        let desc = TF_NewOperation(graph, "Placeholder", "input_\(TFE_Op.placeHolderIndex)")
        let dtype = TFE_TensorHandleDataType(h)
        TF_SetAttrType(desc, "dtype", dtype)
        let result = TF_FinishOperation(desc, status)
        checkOk(status)
        TFE_Op.placeHolderIndex += 1
        let input = TF_Output(oper: result, index: 0)
        TFE_OpAddInput(op, TFE_NewTensorHandleFromTFOutput(input, dtype), status)
        checkOk(status)
        operands.append((inputHandle, input, h))
      }
    case LazyTensorHandle.sym(let argOp): do {
        guard let graphOp = argOp.graphOp else { assert(false) }
        let dtype = TF_OperationOutputType(graphOp)
        TFE_OpAddInput(op, TFE_NewTensorHandleFromTFOutput(graphOp, dtype), self.status)
        checkOk(self.status)
        operands.append((inputHandle, graphOp, nil))
      }
    }
    return 1
  }

  @inlinable @inline(__always)
  internal func addInput(_ inputHandle: ResourceHandle) -> Int {
    TFE_OpAddInput(op, inputHandle._cTensorHandle, status)
    checkOk(status)
    return 1
  }

  @inlinable @inline(__always)
  internal func addInput(_ inputHandle: VariantHandle) -> Int {
    TFE_OpAddInput(op, inputHandle._cTensorHandle, status)
    checkOk(status)
    return 1
  }

  @inlinable @inline(__always)
  mutating internal func lazyAddInput<Scalar: TensorFlowScalar>(_ input: Tensor<Scalar>) -> Int {
    return addInput(input.handle)
  }

  @inlinable @inline(__always)
  internal func addInput<Scalar: TensorFlowScalar>(_ input: Tensor<Scalar>) -> Int {
    TFE_OpAddInput(op, input.handle._cTensorHandle, status)
    checkOk(status)
    return 1
  }

  @inlinable @inline(__always)
  internal func addInput(_ input: StringTensor) -> Int {
    TFE_OpAddInput(op, input.handle._cTensorHandle, status)
    checkOk(status)
    return 1
  }

  @inlinable @inline(__always)
  internal func addInputList<T: TensorArrayProtocol>(_ input: T) -> Int {
    let count = input._tensorHandleCount
    var buffer = UnsafeMutableBufferPointer<CTensorHandle>.allocate(capacity: Int(count))
    defer { buffer.deallocate() }
    let pointer = UnsafeMutablePointer<OpaquePointer?>(buffer.baseAddress)
    input._unpackTensorHandles(into: buffer.baseAddress)
    TFE_OpAddInputList(op, pointer, count, status)
    // TODO: checkOk(status)
    return Int(count)
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: Bool) {
    TFE_OpSetAttrBool(op, name, value ? 1 : 0)
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: Int) {
    TFE_OpSetAttrInt(op, name, Int64(value))
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: Int32) {
    TFE_OpSetAttrInt(op, name, Int64(value))
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: Int64) {
    TFE_OpSetAttrInt(op, name, value)
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: Float) {
    TFE_OpSetAttrFloat(op, name, value)
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: Double) {
    TFE_OpSetAttrFloat(op, name, Float(value))
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: String) {
    value.utf8CString.withUnsafeBufferPointer { buffer in
      // utf8CString is null-terminated; TFE_OpSetAttrString wants
      // non-null-terminated.
      TFE_OpSetAttrString(op, name, buffer.baseAddress, buffer.count - 1)
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: TensorDataType) {
    TFE_OpSetAttrType(op, name, value._cDataType)
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: TensorShape) {
    let dimensions: [Int64] = value.dimensions.map(Int64.init)
    dimensions.withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrShape(op, name, buffer.baseAddress, Int32(buffer.count), status)
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: TensorShape?) {
    guard let shape = value else {
      TFE_OpSetAttrShape(op, name, nil, -1, status)
      return
    }
    setAttr(name, shape)
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [Bool]) {
    value.map({ $0 ? UInt8(1) : UInt8(0) }).withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrBoolList(op, name, buffer.baseAddress, Int32(buffer.count))
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [Int]) {
    setAttr(name, value.map(Int64.init))
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [Int32]) {
    setAttr(name, value.map(Int64.init))
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [Int64]) {
    value.withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrIntList(op, name, buffer.baseAddress, Int32(buffer.count))
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [Float]) {
    value.withUnsafeBufferPointer { buffer in
      TFE_OpSetAttrFloatList(op, name, buffer.baseAddress, Int32(buffer.count))
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [Double]) {
    setAttr(name, value.map(Float.init))
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [String]) {
    // Collect all the strings' utf8 bytes into a single array so that we can
    // address all the strings with a single
    // `flattenedStringBytes.withUnsafeBufferPointer`.
    var flattenedStringBytes: [CChar] = []
    var lengths: [Int] = []
    for string in value {
      // Don't include the null-terminator because TFE_OpSetAttrStringList uses
      // lengths instead of null-terminators.
      let stringBytes = string.utf8CString.dropLast()
      flattenedStringBytes.append(contentsOf: stringBytes)
      lengths.append(stringBytes.count)
    }

    // Calculate the addresses of all the strings within our single buffer, and
    // then call TFE_OpSetAttrStringList.
    flattenedStringBytes.withUnsafeBufferPointer { flattenedStringBytesBuffer in
      var stringAddrs: [UnsafeRawPointer?] = []
      var currentStringAddr =
        flattenedStringBytesBuffer.baseAddress.map(UnsafeRawPointer.init)
      for length in lengths {
        stringAddrs.append(currentStringAddr)
        currentStringAddr = currentStringAddr?.advanced(by: length)
      }

      stringAddrs.withUnsafeBufferPointer { stringAddrsBuffer in
        lengths.withUnsafeBufferPointer { lengthsBuffer in
          TFE_OpSetAttrStringList(op, name, stringAddrsBuffer.baseAddress,
            lengthsBuffer.baseAddress, Int32(value.count))
        }
      }
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [TensorDataType]) {
    value.withUnsafeBufferPointer { buffer in
      buffer.withMemoryRebound(to: TF_DataType.self) { reboundBuffer in
        TFE_OpSetAttrTypeList(op, name, reboundBuffer.baseAddress, Int32(reboundBuffer.count))
      }
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [TensorShape]) {
    let flattenedDims = value.flatMap { $0.dimensions.map(Int64.init) }
    let ranks = value.map { Int32($0.rank) }
    flattenedDims.withUnsafeBufferPointer { flattenedDimsBuffer in
      var dimsPtr: UnsafePointer<Int64>? = flattenedDimsBuffer.baseAddress
      var dims: [UnsafePointer<Int64>?] = []
      for rank in ranks {
        dims.append(dimsPtr)
        if rank >= 0 {
          dimsPtr = dimsPtr.map { $0.advanced(by: Int(rank)) }
        }
      }
      dims.withUnsafeMutableBufferPointer { dimsBuffer in
        ranks.withUnsafeBufferPointer { ranksBuffer in
          TFE_OpSetAttrShapeList(
            op, name, dimsBuffer.baseAddress, ranksBuffer.baseAddress,
            Int32(ranksBuffer.count), status)
        }
      }
    }
  }

  @inlinable @inline(__always)
  internal func setAttr(_ name: String, _ value: [TensorShape?]) {
    let flattenedDims = value.flatMap { (tensorShapeOpt) -> [Int64] in
      if let tensorShape = tensorShapeOpt {
        return tensorShape.dimensions.map(Int64.init)
      }
      return []
    }
    let ranks = value.map { shape in (shape?.rank).map(Int32.init) ?? -1 }
    flattenedDims.withUnsafeBufferPointer { flattenedDimsBuffer in
      var dimsPtr: UnsafePointer<Int64>? = flattenedDimsBuffer.baseAddress
      var dims: [UnsafePointer<Int64>?] = []
      for rank in ranks {
        dims.append(dimsPtr)
        if rank >= 0 {
          dimsPtr = dimsPtr.map { $0.advanced(by: Int(rank)) }
        }
      }
      dims.withUnsafeMutableBufferPointer { dimsBuffer in
        ranks.withUnsafeBufferPointer { ranksBuffer in
          TFE_OpSetAttrShapeList(
            op, name, dimsBuffer.baseAddress, ranksBuffer.baseAddress,
            Int32(ranksBuffer.count), status)
        }
      }
    }
  }

  @inlinable @inline(__always)
  internal func setAttr<In: TensorGroup, Out: TensorGroup>(_ name: String, _ value: (In) -> Out) {
    _tffunc(value).utf8CString.withUnsafeBufferPointer { buffer in
      // utf8CString is null-terminated; TFE_OpSetAttrFunctionName wants
      // non-null-terminated.
      TFE_OpSetAttrFunctionName(op, name, buffer.baseAddress, buffer.count - 1)
    }
  }

  /// **WARNING:** After constructing a `TFE_Op`, any one of its `execute` methods must be called
  /// *exactly once*. If not called, then a memory leak is introduced due to the underlying
  /// TensorFlow eager op object not being freed. If called more than once, then a SEGFAULT may
  /// occur due to trying to execute a TensorFlow eager op that has already been freed.

  @inlinable @inline(__always)
  internal mutating func lazyExecute<T: Numeric & TensorFlowScalar>(
    _ count0: Int
  ) -> (Tensor<T>) {
    print("My execute called!\n")
    // Initialize graphOp field..
    updateGraphOp()
    return Tensor<T>(handle: TensorHandle<T>(_lazy: self))
  }

  @inlinable @inline(__always)
  internal func execute() {
    var count: Int32 = 0
    var unused: CTensorHandle?
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, &unused, &count, status)
    checkOk(status)
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol>(
    _ count0: Int
  ) -> (T0) {
    var count = Int32(count0)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int
  ) -> (T0, T1) {
    var count = Int32(count0) + Int32(count1)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int
  ) -> (T0, T1, T2) {
    var count = Int32(count0) + Int32(count1) + Int32(count2)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int
  ) -> (T0, T1, T2, T3) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int
  ) -> (T0, T1, T2, T3, T4) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int
  ) -> (T0, T1, T2, T3, T4, T5) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6) + Int32(count7)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let offset7 = offset6 + Int32(count6)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6),
      T7.init(_owning: buffer.advanced(by: Int(offset7)), count: count7))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol, T8 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int,
    _ count8: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6) + Int32(count7) + Int32(count8)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let offset7 = offset6 + Int32(count6)
    let offset8 = offset7 + Int32(count7)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6),
      T7.init(_owning: buffer.advanced(by: Int(offset7)), count: count7),
      T8.init(_owning: buffer.advanced(by: Int(offset8)), count: count8))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal func execute<T0 : TensorArrayProtocol, T1 : TensorArrayProtocol, T2 : TensorArrayProtocol, T3 : TensorArrayProtocol, T4 : TensorArrayProtocol, T5 : TensorArrayProtocol, T6 : TensorArrayProtocol, T7 : TensorArrayProtocol, T8 : TensorArrayProtocol, T9 : TensorArrayProtocol>(
    _ count0: Int,
    _ count1: Int,
    _ count2: Int,
    _ count3: Int,
    _ count4: Int,
    _ count5: Int,
    _ count6: Int,
    _ count7: Int,
    _ count8: Int,
    _ count9: Int
  ) -> (T0, T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    var count = Int32(count0) + Int32(count1) + Int32(count2) + Int32(count3) + Int32(count4) + Int32(count5) + Int32(count6) + Int32(count7) + Int32(count8) + Int32(count9)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    _TFCOpSetDeviceFromScope(op, status)
    checkOk(status)
    _TFCEagerExecute(op, UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)
    let offset0 = Int32(0)
    let offset1 = offset0 + Int32(count0)
    let offset2 = offset1 + Int32(count1)
    let offset3 = offset2 + Int32(count2)
    let offset4 = offset3 + Int32(count3)
    let offset5 = offset4 + Int32(count4)
    let offset6 = offset5 + Int32(count5)
    let offset7 = offset6 + Int32(count6)
    let offset8 = offset7 + Int32(count7)
    let offset9 = offset8 + Int32(count8)
    let result = (
      T0.init(_owning: buffer.advanced(by: Int(offset0)), count: count0),
      T1.init(_owning: buffer.advanced(by: Int(offset1)), count: count1),
      T2.init(_owning: buffer.advanced(by: Int(offset2)), count: count2),
      T3.init(_owning: buffer.advanced(by: Int(offset3)), count: count3),
      T4.init(_owning: buffer.advanced(by: Int(offset4)), count: count4),
      T5.init(_owning: buffer.advanced(by: Int(offset5)), count: count5),
      T6.init(_owning: buffer.advanced(by: Int(offset6)), count: count6),
      T7.init(_owning: buffer.advanced(by: Int(offset7)), count: count7),
      T8.init(_owning: buffer.advanced(by: Int(offset8)), count: count8),
      T9.init(_owning: buffer.advanced(by: Int(offset9)), count: count9))
    buffer.deallocate()
    TFE_DeleteOp(op)
    TF_DeleteStatus(status)
    return result
  }

  @inlinable @inline(__always)
  internal mutating func updateGraphOp()  {
    let cTraceContext = _ExecutionContext.global.traceContext.cTraceContext
    // Device?
    var count = Int32(10)
    let buffer: UnsafeMutablePointer<CTensorHandle> =
      UnsafeMutablePointer.allocate(capacity: Int(count))
    let tfOp = TFE_AddEagerOpToGraph(op, cTraceContext,
      UnsafeMutablePointer<CTensorHandle?>(buffer), &count, status)
    checkOk(status)

    // TODO: delete all the handles...
    //let output: CTensorHandle = buffer.advanced(by: Int(offset0))
    buffer.deallocate()

    // TODO: assuming one output for now.
    graphOp = TF_Output(oper: tfOp!, index: 0)
  }

  struct GraphDesc {
    var opers: Set</*CTFOperation*/OpaquePointer?>
    var inputs: [TF_Output]
    var values: [CTensorHandle]
  }

  func collectOperations(_ res: inout GraphDesc) {
    let (inserted, _) =  res.opers.insert(graphOp!.oper)
    if !inserted { return }
    for  (anyHandle, graphOp, tensorHandle) in operands {
      switch (anyHandle.lazyHandle) {
        case LazyTensorHandle.conc(/*TODO: Is this right?*/_): do {
          res.inputs.append(graphOp)
          res.values.append(tensorHandle!)
        }
        case LazyTensorHandle.sym(let argOp):
          argOp.collectOperations(&res)
      }
    }
  }

  //@inlinable @inline(__always)
  func evaluate() -> CTensorHandle {
    var desc = GraphDesc(opers: [], inputs: [], values: [])
    collectOperations(&desc)
    let tracedFunctionName =
      "lazyTrace_\(TFE_Op.traceGraphFunctionCounter)"
    TFE_Op.traceGraphFunctionCounter += 1

    let eagerContext = _TFCGetGlobalEagerContext()
    Array(desc.opers).withUnsafeBufferPointer {opers in
      let graph = _ExecutionContext.global.traceContext.graph
      let base = opers.baseAddress
      let tracedGraphFn =
      TF_GraphToFunction(graph, tracedFunctionName,
        /*append_hash_to_fn_name*/ 0,
        /*num_opers*/ Int32(desc.opers.count),
        /*opers*/ base,
        /*numinputs*/ Int32(desc.inputs.count),
        /*inputs*/ desc.inputs,
        /*noutputs*/ Int32(1),
        /*outputs*/ [graphOp!],
        /*outputnames*/ nil,
        /*functionoptions*/ nil, "", status)
      checkOk(status)
      TFE_ContextAddFunction(eagerContext, tracedGraphFn, status)

      var len: Int = 0
      let funcDebugStr = TF_FunctionDebugString(tracedGraphFn, &len)!
      debugLog("The traced function is:\n\(String(cString: funcDebugStr))")
      free(funcDebugStr)
    }

    let eagerOp: CTFEOp! = TFE_NewOp(eagerContext, tracedFunctionName, status)
    defer { TFE_DeleteOp(eagerOp) }
    checkOk(status)

    let deviceName = _ExecutionContext.global.currentDeviceName
    if let deviceName = deviceName {
      debugLog("Placing the trace func on device \(deviceName).")
      TFE_OpSetDevice(eagerOp, deviceName, status)
      checkOk(status)
    }

    for input in desc.values {
      TFE_OpAddInput(eagerOp, input, status)
      checkOk(status)
    }

    // TODO: more than one return value.
    var returnValues = [CTensorHandle?](repeating: nil,
      count: 1)
    var outputReturnValueCount = Int32(1)
    TFE_Execute(eagerOp, &returnValues, &outputReturnValueCount, status)

    return returnValues[0]!
  }
}