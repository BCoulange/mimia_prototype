// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspection_photo.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspectionPhotoAdapter extends TypeAdapter<InspectionPhoto> {
  @override
  final int typeId = 0;

  @override
  InspectionPhoto read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InspectionPhoto(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InspectionPhoto obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspectionPhotoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
