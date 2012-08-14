-- ELF constants

module( ..., package.seeall )
local cl = require "classes"

local _elfct = cl.new_class( "elfct", "object", "ELF constants" )
getmetatable( getfenv() ).__tostring = function() return "[elfct]" end
setmetatable( _elfct, { __index = getfenv() } )

-- Build a string from its corresponding value
-- Allows easy generation of strings from their corresponding constants
local function build_strings_from_values( prefix )
  local dest = {}
  for k, v in pairs( getfenv() ) do
    if k:find( "^" .. prefix ) then
      dest[ v ] = k:sub( #prefix + 1 )
    end
  end
  setmetatable( dest, { __index = function() return "<UNKNOWN>" end } )
  return dest
end

-- ELF identification
EI_NIDENT = 16
EI_MAG0 = 0
EI_MAG1 = 1
EI_MAG2 = 2
EI_MAG3 = 3
EI_CLASS = 4
EI_DATA = 5
EI_VERSION = 6
EI_OSABI = 7
EI_ABIVERSION = 8

-- ELF classes
ELFCLASSNONE = 0
ELFCLASS32 = 1
ELFCLASS64 = 2

-- ELF data encoding
ELFDATANONE = 0
ELFDATA2LSB = 1
ELFDATA2MSB = 2

-- Versions
EV_NONE = 0
EV_CURRENT = 1

-- Type map
ET_NONE = 0
ET_REL = 1
ET_EXEC = 2
ET_DYN = 3
ET_CORE = 4
ET_LOOS = 0xFE00
ET_HIOS = 0xFEFF
ET_LOPROC = 0xFF00
ET_HIPROC = 0xFFFF
local elf_type_map =
{
  [ ET_NONE ] = "no file type",
  [ ET_REL ] = "relocatable file",
  [ ET_EXEC ] = "executable file",
  [ ET_DYN ] = "shared object file",
  [ ET_CORE ] = "core file"
}
function elf_type_to_str( t )
  if t >= ET_LOPROC and t <= ET_HIPROC then
    return "CPU specific"
  elseif t >= ET_LOOS and t <= ET_HIOS then
    return "OS specific"
  else
    return elf_type_map[ t ]
  end
end

-- ELF machine type
EM_NONE = 0
EM_M32 = 1
EM_SPARC = 2
EM_386 = 3
EM_68K = 4
EM_88K = 5
EM_860 = 7
EM_MIPS = 8
EM_S370 = 9
EM_MIPS_RS3_LE = 10
EM_PARISC = 15
EM_VPP500 = 17
EM_SPARC32PLUS = 18
EM_960 = 19
EM_PPC = 20
EM_PPC64 = 21
EM_S390 = 22
EM_SPU = 23
EM_V800 = 36
EM_FR20 = 37
EM_RH32 = 38
EM_RCE = 39
EM_ARM = 40
EM_ALPHA = 41
EM_SH = 42
EM_SPARCV9 = 43
EM_TRICORE = 44
EM_ARC = 45
EM_H8_300 = 46
EM_H8_300H = 47
EM_H8S = 48
EM_H8_500 = 49
EM_IA_64 = 50
EM_MIPS_X = 51
EM_COLDFIRE = 52
EM_68HC12 = 52
EM_MMA = 54
EM_PCP = 55
EM_NCPU = 56
EM_NDR1 = 57
EM_STARCORE = 58
EM_ME16 = 59
EM_ST100 = 60
EM_TINYJ = 61
EM_X86_64 = 62
EM_PDSP = 63
EM_PDP10 = 64
EM_PDP11 = 65
EM_FX66 = 66
EM_ST9PLUS = 67
EM_ST7 = 68
EM_68HC16 = 69
EM_68HC11 = 70
EM_68HC08 = 71
EM_68HC05 = 72
EM_SVX = 73
EM_ST19 = 74
EM_VAX = 75
EM_CRIS = 76
EM_JAVELIN = 77
EM_FIREPATH = 78
EM_ZSP = 79
EM_MMIX = 80
EM_HUANY = 81
EM_PRISM = 82
EM_AVR = 83
EM_FR30 = 84
EM_D10V = 85
EM_D30V = 86
EM_V850 = 87
EM_M32R = 88
EM_MN10300 = 89
EM_MN10200 = 90
EM_PJ = 91
EM_OPENRISC = 92
EM_ARC_COMPACT = 93
EM_XTENSA = 94
EM_VIDEOCORE = 95
EM_TMM_GPP = 96
EM_NS32K = 97
EM_TPC = 98
EM_SNP1K = 99
EM_ST200 = 100
EM_IP2K = 101
EM_MAX = 102
EM_CR = 103
EM_F2MC16 = 104
EM_MSP430 = 105
EM_BLACKFIN = 106
EM_SE_C33 = 107
EM_SEP = 108
EM_ARCA = 109
EM_UNICORE = 110
EM_EXCESS = 111
EM_DXP = 112
EM_ALTERA_NIOS2 = 113
EM_CRX = 114
EM_XGATE = 115
EM_C166 = 116
EM_M16C = 117
EM_DSPIC30F = 118
EM_CE = 119
EM_M32C = 120
EM_TSK3000 = 131
EM_RS08 = 132
EM_SHARC = 133
EM_ECOG2 = 134
EM_SCORE7 = 135
EM_DSP24 = 136
EM_VIDEOCORE3 = 137
EM_LATTICEMICO32 = 138
EM_SE_C17 = 139
EM_TI_C6000 = 140
EM_TI_C2000 = 141
EM_TI_C5500 = 142
EM_MMDSP_PLUS = 160
EM_CYPRESS_M8C = 161
EM_R32C = 162
EM_TRIMEDIA = 163
EM_QDSP6 = 164
EM_8051 = 165
EM_STXP7X = 166
EM_NDS32 = 167
EM_ECOG1X = 168
EM_MAXQ30 = 169
EM_XIMO16 = 170
EM_MANIK = 171
EM_CRAYNV2 = 172
EM_RX = 173
EM_METAG = 174
EM_MCST_ELBRUS = 175
EM_ECOG16 = 176
EM_CR16 = 177
EM_ETPU = 178
EM_SLE9X = 179
EM_L10M = 180
EM_K10M = 181
EM_AARCH64 = 183
EM_AVR32 = 185
EM_STM8 = 186
EM_TILE64 = 187
EM_TILEPRO = 188
EM_MICROBLAZE = 189
EM_CUDA = 190
EM_TILEGX = 191
EM_CLOUDSHIELD = 192
EM_COREA_1ST = 193
EM_COREA_2ND = 194
EM_ARC_COMPACT2 = 195
EM_OPEN8 = 196
EM_RL78 = 197
EM_VIDEOCORE5 = 198
EM_78KOR = 199
EM_56800EX = 200
elf_machine_map = build_strings_from_values( "EM_" )

-- ELF OSABI
ELFOSABI_NONE = 0
ELFOSABI_HPUX = 1
ELFOSABI_NETBSD = 2
ELFOSABI_GNU = 3
ELFOSABI_SOLARIS = 6
ELFOSABI_AIX = 7
ELFOSABI_IRIX = 8
ELFOSABI_FREEBSD = 9
ELFOSABI_TRU64 = 10
ELFOSABI_MODESTO = 11
ELFOSABI_OPENBSD = 12
ELFOSABI_OPENVMS = 13
ELFOSABI_NSK = 14
ELFOSABI_AROS = 15
ELFOSABI_FENIXOS = 16
elf_osabi_map = build_strings_from_values( "ELFOSABI_" )

-- Special section indexes
SHN_UNDEF = 0
SHN_LORESERVE = 0xFF00
SHN_LOPROC = 0xFF00
SHN_HIPROC = 0xFF1F
SHN_LOOS = 0xFF20
SHN_HIOS = 0xFF3F
SHN_ABS = 0xFFF1
SHN_COMMON = 0xFFF2
SHN_XINDEX = 0xFFFF
SHN_HIRESERVE = 0xFFFF

-- Section types
SHT_NULL = 0
SHT_PROGBITS = 1
SHT_SYMTAB = 2
SHT_STRTAB = 3
SHT_RELA = 4
SHT_HASH = 5
SHT_DYNAMIC = 6
SHT_NOTE = 7
SHT_NOBITS = 8
SHT_REL = 9
SHT_SHLIB = 10
SHT_DYNSYM = 11
SHT_INIT_ARRAY = 14
SHT_FINI_ARRAY = 15
SHT_PREINIT_ARRAY = 16
SHT_GROUP = 17
SHT_SYMTAB_SHNDX = 18
SHT_LOOS = 0x60000000
SHT_HIOS = 0x6FFFFFFF
SHT_LOPROC = 0x70000000
SHT_HIPROC = 0x7FFFFFFF
SHT_LOUSER = 0x80000000
SHT_HIUSER = 0xFFFFFFFF
local elf_secttype_map = build_strings_from_values( "SHT_" )
function elf_secttype_to_str( t )
  if t >= SHT_LOPROC and t <= SHT_HIPROC then
    return "[CPUSPEC]"
  elseif t >= SHT_LOUSER and t <= SHT_HIUSER then
    return "[APPSPEC]"
  elseif t >= SHT_LOOS and t <= SHT_HIOS then
    return "[OSSPEC]"
  else
    return elf_secttype_map[ t ]
  end
end

-- Section flags
SHF_WRITE = 1
SHF_ALLOC = 2
SHF_EXECINSTR = 4
SHF_MERGE = 0x10
SHF_STRINGS = 0x20
SHF_INFO_LINK = 0x40
SHF_LINK_ORDER = 0x80
SHF_OS_NONCONFORMING = 0x100
SHF_GROUP = 0x200
SHF_TLS = 0x400
SHF_MASKOS = 0x0FF00000
SHF_MASKPROC = 0xF0000000

-- Symbol binding
STB_LOCAL = 0
STB_GLOBAL = 1
STB_WEAK = 2
STB_LOOS = 10
STB_HIOS = 12
STB_LOPROC = 13
STB_HIPROC = 15
local elf_symbind_map = build_strings_from_values( "STB_" )
function elf_symbind_to_str( t )
  if t >= STB_LOPROC and t <= STB_HIPROC then
    return "[CPUSPEC]"
  elseif t >= STB_LOOS and t <= STB_HIOS then
    return "[OSSPEC]"
  else
    return elf_symbind_map[ t ]
  end
end

-- Symbol type
STT_NOTYPE = 0
STT_OBJECT = 1
STT_FUNC = 2
STT_SECTION = 3
STT_FILE = 4
STT_COMMON = 5
STT_TLS = 6
STT_LOOS = 10
STT_HIOS = 12
STT_LOPROC = 13
STT_HIPROC = 15
local elf_symtype_map = build_strings_from_values( "STT_" )
function elf_symtype_to_str( t )
  if t >= STT_LOPROC and t <= STT_HIPROC then
    return "[CPUSPEC]"
  elseif t >= STT_LOOS and t <= STT_HIOS then
    return "[OSSPEC]"
  else
    return elf_symtype_map[ t ]
  end
end

-- Symbol visibility
STV_DEFAULT = 0
STV_INTERNAL = 1
STV_HIDDEN = 2
STV_PROTECTED = 3
elf_symvisiblity_map = build_strings_from_values( "STV_" )

