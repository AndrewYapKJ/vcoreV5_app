import 'dart:convert';

List<Job> hmsJobModelFromJson(var str) =>
    List<Job>.from((str).map((x) => Job.fromJson(x)));
String hmsJobModelToJson(List<Job> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Job {
  int? id;
  String? no;
  String? masterOrderNo;
  String? dateTime;
  String? customer;
  String? pickup;
  String? drop;
  String? truckNo;
  String? containerNo;
  String? containerSize;
  String? containerType;
  String? sealNo;
  String? trailerNo;
  String? remarks;
  int? mdtCode;
  String? mdtCodef;
  String? jTypeA;
  dynamic error;
  String? jobType;
  bool? headRun;
  bool? trailerRun;
  String? jobB2B;
  Job? b2bData;
  String? gatePassNo;
  String? gatePassDatetime;
  String? pickOrgName;
  String? pickOrgShortCode;
  String? dropOrgName;
  String? dropOrgShortCode;
  String? pickQty;
  String? dropQty;
  String? tmsDocNo;
  String? tmsIntDocNo;
  String? shippingAgentRefNo;
  String? containerOperator;
  String? deliveryInstruction;
  String? pickOrgContPerNamePh;
  String? dropOrgContPerNamePh;
  String? jobImportExport;
  String? joBpriority;
  String? jobFromSystem;
  String? createdByProjectTempleteTypes;

  Job({
    this.id,
    this.no,
    this.masterOrderNo,
    this.dateTime,
    this.customer,
    this.pickup,
    this.drop,
    this.truckNo,
    this.containerNo,
    this.containerSize,
    this.containerType,
    this.sealNo,
    this.trailerNo,
    this.remarks,
    this.mdtCode,
    this.mdtCodef,
    this.jTypeA,
    this.error,
    this.jobType,
    this.headRun,
    this.trailerRun,
    this.jobB2B,
    this.b2bData,
    this.gatePassNo,
    this.gatePassDatetime,
    this.pickOrgName,
    this.pickOrgShortCode,
    this.dropOrgName,
    this.dropOrgShortCode,
    this.pickQty,
    this.dropQty,
    this.tmsDocNo,
    this.tmsIntDocNo,
    this.shippingAgentRefNo,
    this.containerOperator,
    this.deliveryInstruction,
    this.pickOrgContPerNamePh,
    this.dropOrgContPerNamePh,
    this.jobImportExport,
    this.joBpriority,
    this.jobFromSystem = "HMS",
    this.createdByProjectTempleteTypes,
  });

  factory Job.fromJson(Map<String, dynamic> json) => Job(
    id: (json["ID"]),
    no: _replaceDash(json["NO"]),
    masterOrderNo: _replaceDash(json["MasterOrderNO"]),
    dateTime: _replaceDash(json["DateTime"]),
    customer: _replaceDash(json["Customer"]),
    pickup: _replaceDash(json["Pickup"]),
    drop: _replaceDash(json["Drop"]),
    truckNo: _replaceDash(json["TruckNO"]),
    containerNo: _replaceDash(json["ContainerNO"]),
    containerSize: _replaceDash(json["ContainerSize"]),
    containerType: _replaceDash(json["ContainerType"]),
    sealNo: _replaceDash(json["SealNO"]),
    trailerNo: _replaceDash(json["TrailerNO"]),
    remarks: _replaceDash(json["Remarks"]),
    mdtCode: (json["MDTCode"]),
    mdtCodef: _replaceDash(json["MDTCodef"]),
    jTypeA: _replaceDash(json["JTypeA"]),
    error: _replaceDash(json["error"]),
    jobType: _replaceDash(json["JobType"]),
    headRun: (json["HeadRun"]),
    trailerRun: (json["TrailerRun"]),
    jobB2B: _replaceDash(json["JobB2B"]),
    gatePassNo: _replaceDash(json["GatePassNo"]),
    gatePassDatetime: _replaceDash(json["GatePassDatetime"]),
    pickOrgName: _replaceDash(json["PickOrgName"]),
    pickOrgShortCode: _replaceDash(json["PickOrgShortCode"]),
    dropOrgName: _replaceDash(json["DropOrgName"]),
    dropOrgShortCode: _replaceDash(json["DropOrgShortCode"]),
    pickQty: _replaceDash(json["PickQty"]),
    dropQty: _replaceDash(json["DropQty"]),
    tmsDocNo: _replaceDash(json["TmsDOCNo"]),
    tmsIntDocNo: _replaceDash(json["TmsIntDOCNo"]),
    shippingAgentRefNo: _replaceDash(json["Shipping_Agent_RefNo"]),
    containerOperator: _replaceDash(json["ContainerOperator"]),
    deliveryInstruction: _replaceDash(json["DeliveryInstruction"]),
    pickOrgContPerNamePh: _replaceDash(json["PickOrgContPerNamePh"]),
    dropOrgContPerNamePh: _replaceDash(json["DropOrgContPerNamePh"]),
    jobImportExport: _replaceDash(json["JOBImportExport"]),
    joBpriority: _replaceDash(json["JOBpriority"]),
    jobFromSystem: _replaceDash(json["JobFromSystem"]),
    createdByProjectTempleteTypes: _replaceDash(
      json["CreatedByProjectTempleteTypes"],
    ),
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "NO": no,
    "MasterOrderNO": masterOrderNo,
    "DateTime": dateTime,
    "Customer": customer,
    "Pickup": pickup,
    "Drop": drop,
    "TruckNO": truckNo,
    "ContainerNO": containerNo,
    "ContainerSize": containerSize,
    "ContainerType": containerType,
    "SealNO": sealNo,
    "TrailerNO": trailerNo,
    "Remarks": remarks,
    "MDTCode": mdtCode,
    "MDTCodef": mdtCodef,
    "JTypeA": jTypeA,
    "error": error,
    "JobType": jobType,
    "HeadRun": headRun,
    "TrailerRun": trailerRun,
    "JobB2B": jobB2B,
    "GatePassNo": gatePassNo,
    "GatePassDatetime": gatePassDatetime,
    "PickOrgName": pickOrgName,
    "PickOrgShortCode": pickOrgShortCode,
    "DropOrgName": dropOrgName,
    "DropOrgShortCode": dropOrgShortCode,
    "PickQty": pickQty,
    "DropQty": dropQty,
    "TmsDOCNo": tmsDocNo,
    "TmsIntDOCNo": tmsIntDocNo,
    "Shipping_Agent_RefNo": shippingAgentRefNo,
    "ContainerOperator": containerOperator,
    "DeliveryInstruction": deliveryInstruction,
    "PickOrgContPerNamePh": pickOrgContPerNamePh,
    "DropOrgContPerNamePh": dropOrgContPerNamePh,
    "JOBImportExport": jobImportExport,
    "JOBpriority": joBpriority,
    "JobFromSystem": jobFromSystem,
    "CreatedByProjectTempleteTypes": createdByProjectTempleteTypes,
  };

  static String _replaceDash(dynamic value) {
    if (value == "--" || value == "-") {
      return "";
    }
    return value?.toString() ?? "";
  }
}
