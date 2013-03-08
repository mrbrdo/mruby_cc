require 'ostruct'
require 'active_support/core_ext'

class MrbInstruction
  OPCODES = <<-EOF
OP_NOP=0,/*                                                             */
OP_MOVE,/*      A B     R(A) := R(B)                                    */
OP_LOADL,/*     A Bx    R(A) := Lit(Bx)                                 */
OP_LOADI,/*     A sBx   R(A) := sBx                                     */
OP_LOADSYM,/*   A Bx    R(A) := Sym(Bx)                                 */
OP_LOADNIL,/*   A       R(A) := nil                                     */
OP_LOADSELF,/*  A       R(A) := self                                    */
OP_LOADT,/*     A       R(A) := true                                    */
OP_LOADF,/*     A       R(A) := false                                   */

OP_GETGLOBAL,/* A Bx    R(A) := getglobal(Sym(Bx))                      */
OP_SETGLOBAL,/* A Bx    setglobal(Sym(Bx), R(A))                        */
OP_GETSPECIAL,/*A Bx    R(A) := Special[Bx]                             */
OP_SETSPECIAL,/*A Bx    Special[Bx] := R(A)                             */
OP_GETIV,/*     A Bx    R(A) := ivget(Sym(Bx))                          */
OP_SETIV,/*     A Bx    ivset(Sym(Bx),R(A))                             */
OP_GETCV,/*     A Bx    R(A) := cvget(Sym(Bx))                          */
OP_SETCV,/*     A Bx    cvset(Sym(Bx),R(A))                             */
OP_GETCONST,/*  A Bx    R(A) := constget(Sym(Bx))                       */
OP_SETCONST,/*  A Bx    constset(Sym(Bx),R(A))                          */
OP_GETMCNST,/*  A Bx    R(A) := R(A)::Sym(B)                            */
OP_SETMCNST,/*  A Bx    R(A+1)::Sym(B) := R(A)                          */
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

OP_SEND,/*      A B C   R(A) := call(R(A),mSym(B),R(A+1),...,R(A+C))    */
OP_SENDB,/*     A B C   R(A) := call(R(A),mSym(B),R(A+1),...,R(A+C),&R(A+C+1))*/
OP_FSEND,/*     A B C   R(A) := fcall(R(A),mSym(B),R(A+1),...,R(A+C-1)) */
OP_CALL,/*      A B C   R(A) := self.call(R(A),.., R(A+C))              */
OP_SUPER,/*     A B C   R(A) := super(R(A+1),... ,R(A+C-1))             */
OP_ARGARY,/*    A Bx    R(A) := argument array (16=6:1:5:4)             */
OP_ENTER,/*     Ax      arg setup according to flags (24=5:5:1:5:5:1:1) */
OP_KARG,/*      A B C   R(A) := kdict[mSym(B)]; if C kdict.rm(mSym(B))  */
OP_KDICT,/*     A C     R(A) := kdict                                   */

OP_RETURN,/*    A B     return R(A) (B=normal,in-block return/break)    */
OP_TAILCALL,/*  A B C   return call(R(A),mSym(B),*R(C))                 */
OP_BLKPUSH,/*   A Bx    R(A) := block (16=6:1:5:4)                      */

OP_ADD,/*       A B C   R(A) := R(A)+R(A+1) (mSyms[B]=:+,C=1)           */
OP_ADDI,/*      A B C   R(A) := R(A)+C (mSyms[B]=:+)                    */
OP_SUB,/*       A B C   R(A) := R(A)-R(A+1) (mSyms[B]=:-,C=1)           */
OP_SUBI,/*      A B C   R(A) := R(A)-C (mSyms[B]=:-)                    */
OP_MUL,/*       A B C   R(A) := R(A)*R(A+1) (mSyms[B]=:*,C=1)           */
OP_DIV,/*       A B C   R(A) := R(A)/R(A+1) (mSyms[B]=:/,C=1)           */
OP_EQ,/*        A B C   R(A) := R(A)==R(A+1) (mSyms[B]=:==,C=1)         */
OP_LT,/*        A B C   R(A) := R(A)<R(A+1)  (mSyms[B]=:<,C=1)          */
OP_LE,/*        A B C   R(A) := R(A)<=R(A+1) (mSyms[B]=:<=,C=1)         */
OP_GT,/*        A B C   R(A) := R(A)>R(A+1)  (mSyms[B]=:>,C=1)          */
OP_GE,/*        A B C   R(A) := R(A)>=R(A+1) (mSyms[B]=:>=,C=1)         */

OP_ARRAY,/*     A B C   R(A) := ary_new(R(B),R(B+1)..R(B+C))            */
OP_ARYCAT,/*    A B     ary_cat(R(A),R(B))                              */
OP_ARYPUSH,/*   A B     ary_push(R(A),R(B))                             */
OP_AREF,/*      A B C   R(A) := R(B)[C]                                 */
OP_ASET,/*      A B C   R(B)[C] := R(A)                                 */
OP_APOST,/*     A B C   *R(A),R(A+1)..R(A+C) := R(A)                    */

OP_STRING,/*    A Bx    R(A) := str_dup(Lit(Bx))                        */
OP_STRCAT,/*    A B     str_cat(R(A),R(B))                              */

OP_HASH,/*      A B C   R(A) := hash_new(R(B),R(B+1)..R(B+C))           */
OP_LAMBDA,/*    A Bz Cz R(A) := lambda(SEQ[Bz],Cm)                      */
OP_RANGE,/*     A B C   R(A) := range_new(R(B),R(B+1),C)                */

OP_OCLASS,/*    A       R(A) := ::Object                                */
OP_CLASS,/*     A B     R(A) := newclass(R(A),mSym(B),R(A+1))           */
OP_MODULE,/*    A B     R(A) := newmodule(R(A),mSym(B))                 */
OP_EXEC,/*      A Bx    R(A) := blockexec(R(A),SEQ[Bx])                 */
OP_METHOD,/*    A B     R(A).newmethod(mSym(B),R(A+1))                  */
OP_SCLASS,/*    A B     R(A) := R(B).singleton_class                    */
OP_TCLASS,/*    A       R(A) := target_class                            */

OP_DEBUG,/*     A       print R(A)                                      */
OP_STOP,/*              stop VM                                         */
OP_ERR,/*       Bx      raise RuntimeError with message Lit(Bx)         */

OP_RSVD1,/*             reserved instruction #1                         */
OP_RSVD2,/*             reserved instruction #2                         */
OP_RSVD3,/*             reserved instruction #3                         */
OP_RSVD4,/*             reserved instruction #4                         */
OP_RSVD5,/*             reserved instruction #5                         */
EOF
  .split("\n").reject(&:blank?).map {|s| s.gsub(/[,=].*/, "") }

  MAXARG_Bx = ((1<<16)-1)
  MAXARG_sBx = (MAXARG_Bx>>1)

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
  RITE_FILE_FORMAT_VER = "00090000"
  RITE_IREP_IDENFIFIER = "S"
  MRB_VTYPE = [
    :MRB_TT_FALSE,
    :MRB_TT_FREE,
    :MRB_TT_TRUE,
    :MRB_TT_FIXNUM,
    :MRB_TT_SYMBOL,
    :MRB_TT_UNDEF,
    :MRB_TT_FLOAT,
    :MRB_TT_VOIDP,
    :MRB_TT_MAIN,
    :MRB_TT_OBJECT,
    :MRB_TT_CLASS,
    :MRB_TT_MODULE,
    :MRB_TT_ICLASS,
    :MRB_TT_SCLASS,
    :MRB_TT_PROC,
    :MRB_TT_ARRAY,
    :MRB_TT_HASH,
    :MRB_TT_STRING,
    :MRB_TT_RANGE,
    :MRB_TT_REGEX,
    :MRB_TT_STRUCT,
    :MRB_TT_EXCEPTION,
    :MRB_TT_MATCH,
    :MRB_TT_FILE,
    :MRB_TT_ENV,
    :MRB_TT_DATA,
    :MRB_TT_MAXDEFINE
  ]

  attr_reader :header, :ireps
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
    read_ireps
  end

  def hex_uint(str)
    str.to_i(16)
  end

  def read_header
    fields = [
      [:rbfi, 4],
      [:rbfv, 8],
      [:risv, 8],
      [:rct, 8],
      [:rcv, 8],
      [:rbds, 8],
      [:nirep, 4, :hex_uint],
      [:sirep, 4],
      [:rsv, 8],
      [:hcrc, 4]
    ]
    r = OpenStruct.new
    fields.each do |field|
      r.send("#{field[0]}=", @file.read(field[1]))
      case field[2]
      when :hex_uint
        r.send("#{field[0]}=", hex_uint(r.send(field[0])))
      end
    end

    if r.rbfi != RITE_FILE_IDENFIFIER
      raise HeaderError
    end
    if r.rbfv != RITE_FILE_FORMAT_VER
      raise HeaderError
    end
    @header = r
  end

  def read_irep
    irep = OpenStruct.new
    len = hex_uint(@file.read(8))
    if @file.read(1) != RITE_IREP_IDENFIFIER
      raise DataError
    end
    @file.read(1) # class or module
    irep.nlocals = hex_uint(@file.read(4))
    irep.nregs = hex_uint(@file.read(4))
    irep.offset = hex_uint(@file.read(4))
    @file.seek(irep.offset, IO::SEEK_CUR)

    len = hex_uint(@file.read(8))
    irep.iseqs = len.times.map do
      MrbInstruction.new(hex_uint(@file.read(8)))
    end
    @file.seek(4, IO::SEEK_CUR) # crc

    # pool
    len = hex_uint(@file.read(8))
    irep.pool = len.times.map do
      tt = hex_uint(@file.read(2))
      pdl = hex_uint(@file.read(4))
      buf = @file.read(pdl)

      case MRB_VTYPE[tt]
      when :MRB_TT_FIXNUM
        buf.to_i
      when :MRB_TT_FLOAT
        buf.to_f
      when :MRB_TT_STRING
        buf
      when :MRB_TT_REGEX
        Regexp.new(buf)
      else
        nil
      end
    end
    @file.seek(4, IO::SEEK_CUR) # crc

    # syms
    len = hex_uint(@file.read(8))
    irep.syms = len.times.map do
      snl = hex_uint(@file.read(4))
      if snl == 0xFFFF
        0
      else
        @file.read(snl)
      end
    end
    @file.seek(4, IO::SEEK_CUR) # crc

    irep
  end

  def read_ireps
    len = header.nirep

    @ireps = []
    len.times do
      @ireps.push(read_irep)
    end

  end
end
