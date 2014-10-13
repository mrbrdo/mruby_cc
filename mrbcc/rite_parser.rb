require 'ostruct'
require 'active_support/core_ext'

class MrbInstruction
  OPCODES = <<-EOF
OP_NOP=0,/*                                                             */
OP_MOVE,/*      A B     R(A) := R(B)                                    */
OP_LOADL,/*     A Bx    R(A) := Pool(Bx)                                */
OP_LOADI,/*     A sBx   R(A) := sBx                                     */
OP_LOADSYM,/*   A Bx    R(A) := Syms(Bx)                                */
OP_LOADNIL,/*   A       R(A) := nil                                     */
OP_LOADSELF,/*  A       R(A) := self                                    */
OP_LOADT,/*     A       R(A) := true                                    */
OP_LOADF,/*     A       R(A) := false                                   */

OP_GETGLOBAL,/* A Bx    R(A) := getglobal(Syms(Bx))                     */
OP_SETGLOBAL,/* A Bx    setglobal(Syms(Bx), R(A))                       */
OP_GETSPECIAL,/*A Bx    R(A) := Special[Bx]                             */
OP_SETSPECIAL,/*A Bx    Special[Bx] := R(A)                             */
OP_GETIV,/*     A Bx    R(A) := ivget(Syms(Bx))                         */
OP_SETIV,/*     A Bx    ivset(Syms(Bx),R(A))                            */
OP_GETCV,/*     A Bx    R(A) := cvget(Syms(Bx))                         */
OP_SETCV,/*     A Bx    cvset(Syms(Bx),R(A))                            */
OP_GETCONST,/*  A Bx    R(A) := constget(Syms(Bx))                      */
OP_SETCONST,/*  A Bx    constset(Syms(Bx),R(A))                         */
OP_GETMCNST,/*  A Bx    R(A) := R(A)::Syms(Bx)                          */
OP_SETMCNST,/*  A Bx    R(A+1)::Syms(Bx) := R(A)                        */
OP_GETUPVAR,/*  A B C   R(A) := uvget(B,C)                              */
OP_SETUPVAR,/*  A B C   uvset(B,C,R(A))                                 */

OP_JMP,/*       sBx     pc+=sBx                                         */
OP_JMPIF,/*     A sBx   if R(A) pc+=sBx                                 */
OP_JMPNOT,/*    A sBx   if !R(A) pc+=sBx                                */
OP_ONERR,/*     sBx     rescue_push(pc+sBx)                             */
OP_RESCUE,/*    A       clear(exc); R(A) := exception (ignore when A=0) */
OP_POPERR,/*    A       A.times{rescue_pop()}                           */
OP_RAISE,/*     A       raise(R(A))                                     */
OP_EPUSH,/*     Bx      ensure_push(SEQ[Bx])                            */
OP_EPOP,/*      A       A.times{ensure_pop().call}                      */

OP_SEND,/*      A B C   R(A) := call(R(A),Syms(B),R(A+1),...,R(A+C))    */
OP_SENDB,/*     A B C   R(A) := call(R(A),Syms(B),R(A+1),...,R(A+C),&R(A+C+1))*/
OP_FSEND,/*     A B C   R(A) := fcall(R(A),Syms(B),R(A+1),...,R(A+C-1)) */
OP_CALL,/*      A       R(A) := self.call(frame.argc, frame.argv)       */
OP_SUPER,/*     A C     R(A) := super(R(A+1),... ,R(A+C+1))             */
OP_ARGARY,/*    A Bx    R(A) := argument array (16=6:1:5:4)             */
OP_ENTER,/*     Ax      arg setup according to flags (23=5:5:1:5:5:1:1) */
OP_KARG,/*      A B C   R(A) := kdict[Syms(B)]; if C kdict.rm(Syms(B))  */
OP_KDICT,/*     A C     R(A) := kdict                                   */

OP_RETURN,/*    A B     return R(A) (B=normal,in-block return/break)    */
OP_TAILCALL,/*  A B C   return call(R(A),Syms(B),*R(C))                 */
OP_BLKPUSH,/*   A Bx    R(A) := block (16=6:1:5:4)                      */

OP_ADD,/*       A B C   R(A) := R(A)+R(A+1) (Syms[B]=:+,C=1)            */
OP_ADDI,/*      A B C   R(A) := R(A)+C (Syms[B]=:+)                     */
OP_SUB,/*       A B C   R(A) := R(A)-R(A+1) (Syms[B]=:-,C=1)            */
OP_SUBI,/*      A B C   R(A) := R(A)-C (Syms[B]=:-)                     */
OP_MUL,/*       A B C   R(A) := R(A)*R(A+1) (Syms[B]=:*,C=1)            */
OP_DIV,/*       A B C   R(A) := R(A)/R(A+1) (Syms[B]=:/,C=1)            */
OP_EQ,/*        A B C   R(A) := R(A)==R(A+1) (Syms[B]=:==,C=1)          */
OP_LT,/*        A B C   R(A) := R(A)<R(A+1)  (Syms[B]=:<,C=1)           */
OP_LE,/*        A B C   R(A) := R(A)<=R(A+1) (Syms[B]=:<=,C=1)          */
OP_GT,/*        A B C   R(A) := R(A)>R(A+1)  (Syms[B]=:>,C=1)           */
OP_GE,/*        A B C   R(A) := R(A)>=R(A+1) (Syms[B]=:>=,C=1)          */

OP_ARRAY,/*     A B C   R(A) := ary_new(R(B),R(B+1)..R(B+C))            */
OP_ARYCAT,/*    A B     ary_cat(R(A),R(B))                              */
OP_ARYPUSH,/*   A B     ary_push(R(A),R(B))                             */
OP_AREF,/*      A B C   R(A) := R(B)[C]                                 */
OP_ASET,/*      A B C   R(B)[C] := R(A)                                 */
OP_APOST,/*     A B C   *R(A),R(A+1)..R(A+C) := R(A)                    */

OP_STRING,/*    A Bx    R(A) := str_dup(Lit(Bx))                        */
OP_STRCAT,/*    A B     str_cat(R(A),R(B))                              */

OP_HASH,/*      A B C   R(A) := hash_new(R(B),R(B+1)..R(B+C))           */
OP_LAMBDA,/*    A Bz Cz R(A) := lambda(SEQ[Bz],Cz)                      */
OP_RANGE,/*     A B C   R(A) := range_new(R(B),R(B+1),C)                */

OP_OCLASS,/*    A       R(A) := ::Object                                */
OP_CLASS,/*     A B     R(A) := newclass(R(A),Syms(B),R(A+1))           */
OP_MODULE,/*    A B     R(A) := newmodule(R(A),Syms(B))                 */
OP_EXEC,/*      A Bx    R(A) := blockexec(R(A),SEQ[Bx])                 */
OP_METHOD,/*    A B     R(A).newmethod(Syms(B),R(A+1))                  */
OP_SCLASS,/*    A B     R(A) := R(B).singleton_class                    */
OP_TCLASS,/*    A       R(A) := target_class                            */

OP_DEBUG,/*     A B C   print R(A),R(B),R(C)                            */
OP_STOP,/*              stop VM                                         */
OP_ERR,/*       Bx      raise RuntimeError with message Lit(Bx)         */

OP_RSVD1,/*             reserved instruction #1                         */
OP_RSVD2,/*             reserved instruction #2                         */
OP_RSVD3,/*             reserved instruction #3                         */
OP_RSVD4,/*             reserved instruction #4                         */
OP_RSVD5,/*             reserved instruction #5                         */
EOF
  .split("\n").reject(&:blank?).map {|s| s.gsub(/[,=].*/, "") }

  MAXARG_Bx = 0xffff
  MAXARG_sBx = MAXARG_Bx>>1

  def initialize(instr_code)
    @instr = instr_code
    @opcode = @instr & 0x7f
    @opcode_name = OPCODES[@opcode]
  end

  def opcode
    @opcode_name
  end

  def GETARG_A
    (@instr >> 23) & 0x1ff
  end

  def GETARG_B
    (@instr >> 14) & 0x1ff
  end

  def GETARG_C
    (@instr >> 7) & 0x7f
  end

  def GETARG_Bx
    (@instr >> 7) & 0xffff
  end

  def GETARG_sBx
    self.GETARG_Bx - MAXARG_sBx
  end

  def GETARG_Ax
    (@instr >> 7) & 0x1ffffff
  end

  def GETARG_UNPACK_b(n1, n2)
    (@instr >> (7+n2)) & (((1<<n1)-1))
  end

  def GETARG_UNPACK_c(n1, n2)
    (@instr >> 7) & (((1<<n2)-1))
  end

  def GETARG_b
    self.GETARG_UNPACK_b(14, 2)
  end

  def GETARG_c
    self.GETARG_UNPACK_c(14, 2)
  end

  def to_s
    [@opcode_name, self.GETARG_A, self.GETARG_B, self.GETARG_C].inspect
  end
end

class RiteParser
  class HeaderError < StandardError ; end
  class DataError < StandardError ; end

  RITE_FILE_IDENFIFIER = "RITE"
  RITE_FILE_FORMAT_VER = "0002"
  RITE_SECTION_IREP_IDENTIFIER = "IREP"
  RITE_SECTION_LV_IDENTIFIER = "LVAR"
  RITE_BINARY_EOF = "END\0"
  MRB_DUMP_NULL_SYM_LEN = 0xffff
  RITE_LV_NULL_MARK = 0xffff
  MRB_VTYPE = [
    :IREP_TT_STRING,
    :IREP_TT_FIXNUM,
    :IREP_TT_FLOAT
  ]

  attr_reader :header, :irep
  def initialize(filename)
    @file = File.open(filename, "rb") do |f|
      sio = StringIO.new
      while !f.eof?
        sio << f.read
      end
      sio
    end
    # gotta look into how comments work, this isn't good if we have strings containing # or \n
    #@file.string.gsub!(/\n|\r/, "")
    #@file.string.gsub!(/#.*/, "")
    @file.rewind

    read_header
    read_sections
  end

  def hex_uint(str)
    str.to_i(16)
  end

  def read_header
    data = read_fields([
      [:binary_identify, 4],
      [:binary_version, 4],
      [:binary_crc, 2],
      [:binary_size, 4],
      [:compiler_name, 4],
      [:compiler_version, 4]
    ])

    if data.binary_identify != RITE_FILE_IDENFIFIER
      raise HeaderError
    end
    if data.binary_version != RITE_FILE_FORMAT_VER
      raise HeaderError
    end
    @header = data
  end

  def read_section_irep
    irep = read_fields([
      [:record_size, 4],
      [:nlocals, 2, :bin_uint16],
      [:nregs, 2, :bin_uint16],
      [:rlen, 2, :bin_uint16], # number of child irep
      [:ilen, 4, :bin_uint32]
      ], irep)

    irep.iseqs = irep.ilen.times.map do
      MrbInstruction.new(read_field(4, :bin_uint32))
    end

    # pool
    len = read_field(4, :bin_uint32)
    irep.pool = len.times.map do
      tt = read_field(1, :bin_uint8)
      pool_data_len = read_field(2, :bin_uint16)
      buf = @file.read(pool_data_len)

      case MRB_VTYPE[tt]
      when :IREP_TT_FIXNUM
        buf.to_i
      when :IREP_TT_FLOAT
        buf.to_f
      when :IREP_TT_STRING
        buf
      else
        nil
      end
    end

    # syms
    len = read_field(4, :bin_uint32)
    irep.syms = len.times.map do
      snl = read_field(2, :bin_uint16) # symbol name length
      if snl == MRB_DUMP_NULL_SYM_LEN
        0
      else
        @file.read(snl).tap do
          @file.read(1) # null terminator
        end
      end
    end

    # child ireps
    irep.reps = irep.rlen.times.map do
      read_section_irep
    end

    irep
  end

  def read_lv_record(syms, syms_len, irep)
    irep.lv = (0..(irep.nlocals-2)).map do |i|
      sym_idx = read_field(2, :bin_to_uint16)

      Hash.new.tap do |lv|
        if sym_idx == RITE_LV_NULL_MARK
          lv[:name] = lv[:r] = 0
        else
          if (sym_idx >= syms_len)
            raise "MRB_DUMP_GENERAL_FAILURE: sym_idx >= syms_len"
          else
            lv[:name] = syms[sym_idx]
            lv[:r] = read_field(2, :bin_to_uint16)
          end
        end
      end
    end

    (0...irep.rlen).each do |i|
      read_lv_record(syms, syms_len, irep.reps[i])
    end
  end

  def read_section_lv
    syms_len = read_field(4, :bin_to_uint32)

    (0...syms_len).each do |i|
      str_len = read_field(2, :bin_to_uint16)

      syms[i] = @file.read(str_len)
    end

    read_lv_record(syms, syms_len, irep)
  end

  def read_section
    data = read_fields([
      [:section_identify, 4],
      [:section_size, 4, :bin_uint16]
    ])

    if data.section_identify == RITE_BINARY_EOF
      false
    else
      fpos = @file.pos
      case data.section_identify
      when RITE_SECTION_IREP_IDENTIFIER
        read_fields([[:rite_version, 4]])
        @irep = read_section_irep
      when RITE_SECTION_LV_IDENTIFIER
        fail "LV section appeared before IREP section. Aborting..." unless irep
        read_section_lv
      end
      @file.seek(fpos + data.section_size, IO::SEEK_SET)
      true
    end
  end

  def read_fields(fields, data = nil)
    data ||= OpenStruct.new
    fields.each do |field|
      data.send("#{field[0]}=", read_field(field[1], field[2]))
    end
    data
  end

  def read_field(size, type = nil)
    value = @file.read(size)
    case type
    when :bin_uint32
      (value[0].ord << 24) |
      (value[1].ord << 16) |
      (value[2].ord << 8) |
      value[3].ord
    when :bin_uint16
      (value[0].ord << 8) | value[1].ord
    when :bin_uint8
      value[0].ord
    when :hex_uint
      hex_uint(value)
    else
      value
    end
  end

  def read_sections
    read_section
  end
end
