class Job {
  final int id;
  final String no;
  final String masterOrderNo;
  final String dateTime;
  final String customer;
  final String pickup;
  final String drop;
  final String truckNo;
  final String containerNo;
  final String containerSize;
  final String containerType;
  final String sealNo;
  final String trailerNo;
  final String remarks;
  final int mdtCode;
  final String mdtCodef;
  final String jTypeA;
  final String? error;
  final String jobType;
  final bool headRun;
  final bool trailerRun;
  final String jobB2B;
  final String gatePassNo;
  final String gatePassDatetime;
  final String pickOrgName;
  final String pickOrgShortCode;
  final String dropOrgName;
  final String dropOrgShortCode;
  final String pickQty;
  final String dropQty;
  final String tmsDOCNo;
  final String tmsIntDOCNo;
  final String shippingAgentRefNo;
  final String containerOperator;
  final String deliveryInstruction;
  final String pickOrgContPerNamePh;
  final String dropOrgContPerNamePh;
  final String jobImportExport;
  final String jobPriority;

  Job({
    required this.id,
    required this.no,
    required this.masterOrderNo,
    required this.dateTime,
    required this.customer,
    required this.pickup,
    required this.drop,
    required this.truckNo,
    required this.containerNo,
    required this.containerSize,
    required this.containerType,
    required this.sealNo,
    required this.trailerNo,
    required this.remarks,
    required this.mdtCode,
    required this.mdtCodef,
    required this.jTypeA,
    this.error,
    required this.jobType,
    required this.headRun,
    required this.trailerRun,
    required this.jobB2B,
    required this.gatePassNo,
    required this.gatePassDatetime,
    required this.pickOrgName,
    required this.pickOrgShortCode,
    required this.dropOrgName,
    required this.dropOrgShortCode,
    required this.pickQty,
    required this.dropQty,
    required this.tmsDOCNo,
    required this.tmsIntDOCNo,
    required this.shippingAgentRefNo,
    required this.containerOperator,
    required this.deliveryInstruction,
    required this.pickOrgContPerNamePh,
    required this.dropOrgContPerNamePh,
    required this.jobImportExport,
    required this.jobPriority,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['ID'] ?? 0,
      no: json['NO'] ?? '',
      masterOrderNo: json['MasterOrderNO'] ?? '',
      dateTime: json['DateTime'] ?? '',
      customer: json['Customer'] ?? '',
      pickup: json['Pickup'] ?? '',
      drop: json['Drop'] ?? '',
      truckNo: json['TruckNO'] ?? '--',
      containerNo: json['ContainerNO'] ?? '--',
      containerSize: json['ContainerSize'] ?? '--',
      containerType: json['ContainerType'] ?? '--',
      sealNo: json['SealNO'] ?? '--',
      trailerNo: json['TrailerNO'] ?? '--',
      remarks: json['Remarks'] ?? '--',
      mdtCode: json['MDTCode'] ?? 0,
      mdtCodef: json['MDTCodef'] ?? '0000',
      jTypeA: json['JTypeA'] ?? '',
      error: json['error'],
      jobType: json['JobType'] ?? '1',
      headRun: json['HeadRun'] ?? false,
      trailerRun: json['TrailerRun'] ?? false,
      jobB2B: json['JobB2B'] ?? '0',
      gatePassNo: json['GatePassNo'] ?? '',
      gatePassDatetime: json['GatePassDatetime'] ?? '',
      pickOrgName: json['PickOrgName'] ?? '',
      pickOrgShortCode: json['PickOrgShortCode'] ?? '',
      dropOrgName: json['DropOrgName'] ?? '',
      dropOrgShortCode: json['DropOrgShortCode'] ?? '',
      pickQty: json['PickQty'] ?? '--',
      dropQty: json['DropQty'] ?? '--',
      tmsDOCNo: json['TmsDOCNo'] ?? '--',
      tmsIntDOCNo: json['TmsIntDOCNo'] ?? '--',
      shippingAgentRefNo: json['Shipping_Agent_RefNo'] ?? '',
      containerOperator: json['ContainerOperator'] ?? '',
      deliveryInstruction: json['DeliveryInstruction'] ?? '',
      pickOrgContPerNamePh: json['PickOrgContPerNamePh'] ?? '',
      dropOrgContPerNamePh: json['DropOrgContPerNamePh'] ?? '',
      jobImportExport: json['JOBImportExport'] ?? '',
      jobPriority: json['JOBpriority'] ?? '1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'NO': no,
      'MasterOrderNO': masterOrderNo,
      'DateTime': dateTime,
      'Customer': customer,
      'Pickup': pickup,
      'Drop': drop,
      'TruckNO': truckNo,
      'ContainerNO': containerNo,
      'ContainerSize': containerSize,
      'ContainerType': containerType,
      'SealNO': sealNo,
      'TrailerNO': trailerNo,
      'Remarks': remarks,
      'MDTCode': mdtCode,
      'MDTCodef': mdtCodef,
      'JTypeA': jTypeA,
      'error': error,
      'JobType': jobType,
      'HeadRun': headRun,
      'TrailerRun': trailerRun,
      'JobB2B': jobB2B,
      'GatePassNo': gatePassNo,
      'GatePassDatetime': gatePassDatetime,
      'PickOrgName': pickOrgName,
      'PickOrgShortCode': pickOrgShortCode,
      'DropOrgName': dropOrgName,
      'DropOrgShortCode': dropOrgShortCode,
      'PickQty': pickQty,
      'DropQty': dropQty,
      'TmsDOCNo': tmsDOCNo,
      'TmsIntDOCNo': tmsIntDOCNo,
      'Shipping_Agent_RefNo': shippingAgentRefNo,
      'ContainerOperator': containerOperator,
      'DeliveryInstruction': deliveryInstruction,
      'PickOrgContPerNamePh': pickOrgContPerNamePh,
      'DropOrgContPerNamePh': dropOrgContPerNamePh,
      'JOBImportExport': jobImportExport,
      'JOBpriority': jobPriority,
    };
  }
}
