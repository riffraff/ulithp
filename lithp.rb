# by Fogus
# http://joyofclojure.com

class Lisp
  def initialize
    @env = { 
      :label => lambda { |(name,val), _| @env[name] = val },
      :quote => lambda { |sexpr, _| sexpr[0] },
      :car   => lambda { |(list), _| list[0] },
      :cdr   => lambda { |(list), _| list.drop 1 },
      :cons  => lambda { |(e,cell), _| [e] + cell },
      :eq    => lambda { |(l,r), _| l == r },
      :if    => lambda { |(cond, thn, els), ctx| eval(cond, ctx) ? eval(thn, ctx) : eval(els, ctx) },
      :atom  => lambda { |(sexpr), _| (sexpr.is_a? Symbol) or (sexpr.is_a? Numeric) }
    }
  end

  def apply fn, args, ctx=@env
    return @env[fn].call(args, ctx) if @env[fn].respond_to? :call
    self.eval @env[fn][2], Hash[*(@env[fn][1].zip args).flatten(1)]
  end

  def eval sexpr, ctx=@env
    if @env[:atom].call [sexpr], ctx
      return ctx[sexpr] || sexpr
    end

    fn, *args = sexpr
    args = args.map { |a| self.eval(a, ctx) } if not [:quote, :if].member? fn
    apply(fn, args, ctx)
  end
end

