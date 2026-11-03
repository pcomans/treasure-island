## The `.import` file the street-vegetation texture tools write next to each
## PNG they produce (tools/vegetation/prepare_textures.gd and
## bake_impostors.gd), so a re-pack or re-bake always imports the same way:
## lossless, with a full mip chain. The foliage shader's alpha-scissor cards,
## the atlases' inset cells and transparent-pixel fill, and its mip-level alpha
## boost are all written for mipmaps.
##
## Keeps the existing file's uid so a re-run doesn't churn it; Godot adds the
## imported paths when it next imports.


static func write(path: String) -> Error:
	var import_path := ProjectSettings.globalize_path(path) + ".import"
	var uid_line := ""
	if FileAccess.file_exists(import_path):
		for line in FileAccess.get_file_as_string(import_path).split("\n"):
			if line.begins_with("uid="):
				uid_line = line
	var header: Array[String] = ["[remap]", "", "importer=\"texture\"", "type=\"CompressedTexture2D\""]
	if uid_line != "":
		header.append(uid_line)
	var file := FileAccess.open(import_path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string("\n".join(header + [
		"",
		"[deps]", "", "source_file=\"%s\"" % path, "",
		"[params]", "",
		"compress/mode=0", "compress/high_quality=false", "compress/lossy_quality=0.7",
		"compress/uastc_level=0", "compress/rdo_quality_loss=0.0", "compress/hdr_compression=1",
		"compress/normal_map=0", "compress/channel_pack=0", "mipmaps/generate=true", "mipmaps/limit=-1",
		"roughness/mode=0", "roughness/src_normal=\"\"",
		"process/channel_remap/red=0", "process/channel_remap/green=1", "process/channel_remap/blue=2", "process/channel_remap/alpha=3",
		"process/fix_alpha_border=true", "process/premult_alpha=false", "process/normal_map_invert_y=false",
		"process/hdr_as_srgb=false", "process/hdr_clamp_exposure=false", "process/size_limit=0", "detect_3d/compress_to=1", "",
	]))
	file.close()
	return OK
