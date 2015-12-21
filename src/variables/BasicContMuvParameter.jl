### BasicContMuvParameter

type BasicContMuvParameter{S<:VariableState} <: Parameter{Continuous, Multivariate}
  key::Symbol
  index::Int
  pdf::Union{ContinuousMultivariateDistribution, Void}
  prior::Union{ContinuousMultivariateDistribution, Void}
  setpdf::Union{Function, Void}
  setprior::Union{Function, Void}
  loglikelihood!::Union{Function, Void}
  logprior!::Union{Function, Void}
  logtarget!::Union{Function, Void}
  gradloglikelihood!::Union{Function, Void}
  gradlogprior!::Union{Function, Void}
  gradlogtarget!::Union{Function, Void}
  tensorloglikelihood!::Union{Function, Void}
  tensorlogprior!::Union{Function, Void}
  tensorlogtarget!::Union{Function, Void}
  dtensorloglikelihood!::Union{Function, Void}
  dtensorlogprior!::Union{Function, Void}
  dtensorlogtarget!::Union{Function, Void}
  uptogradlogtarget!::Union{Function, Void}
  uptotensorlogtarget!::Union{Function, Void}
  uptodtensorlogtarget!::Union{Function, Void}
  states::Vector{S}

  function BasicContMuvParameter(
    key::Symbol,
    index::Int,
    pdf::Union{ContinuousMultivariateDistribution, Void},
    prior::Union{ContinuousMultivariateDistribution, Void},
    setpdf::Union{Function, Void},
    setprior::Union{Function, Void},
    ll::Union{Function, Void},
    lp::Union{Function, Void},
    lt::Union{Function, Void},
    gll::Union{Function, Void},
    glp::Union{Function, Void},
    glt::Union{Function, Void},
    tll::Union{Function, Void},
    tlp::Union{Function, Void},
    tlt::Union{Function, Void},
    dtll::Union{Function, Void},
    dtlp::Union{Function, Void},
    dtlt::Union{Function, Void},
    uptoglt::Union{Function, Void},
    uptotlt::Union{Function, Void},
    uptodtlt::Union{Function, Void},
    states::Vector{S}
  )
    args = (setpdf, setprior, ll, lp, lt, gll, glp, glt, tll, tlp, tlt, dtll, dtlp, dtlt, uptoglt, uptotlt, uptodtlt)
    fnames = fieldnames(BasicContMuvParameter)[5:21]

    # Check that all generic functions have correct signature
    for i = 1:17
      if isa(args[i], Function) &&
        isgeneric(args[i]) &&
        !(any([method_exists(args[i], (BasicContMuvParameterState, Vector{S})) for S in subtypes(VariableState)]))
        error("$(fnames[i]) has wrong signature")
      end
    end

    new(
      key,
      index,
      pdf,
      prior,
      setpdf,
      setprior,
      ll,
      lp,
      lt,
      gll,
      glp,
      glt,
      tll,
      tlp,
      tlt,
      dtll,
      dtlp,
      dtlt,
      uptoglt,
      uptotlt,
      uptodtlt,
      states
    )
  end
end

BasicContMuvParameter{S<:VariableState}(
  key::Symbol,
  index::Int,
  pdf::Union{ContinuousMultivariateDistribution, Void},
  prior::Union{ContinuousMultivariateDistribution, Void},
  setpdf::Union{Function, Void},
  setprior::Union{Function, Void},
  ll::Union{Function, Void},
  lp::Union{Function, Void},
  lt::Union{Function, Void},
  gll::Union{Function, Void},
  glp::Union{Function, Void},
  glt::Union{Function, Void},
  tll::Union{Function, Void},
  tlp::Union{Function, Void},
  tlt::Union{Function, Void},
  dtll::Union{Function, Void},
  dtlp::Union{Function, Void},
  dtlt::Union{Function, Void},
  uptoglt::Union{Function, Void},
  uptotlt::Union{Function, Void},
  uptodtlt::Union{Function, Void},
  states::Vector{S}
) =
  BasicContMuvParameter{S}(
    key,
    index,
    pdf,
    prior,
    setpdf,
    setprior,
    ll,
    lp,
    lt,
    gll,
    glp,
    glt,
    tll,
    tlp,
    tlt,
    dtll,
    dtlp,
    dtlt,
    uptoglt,
    uptotlt,
    uptodtlt,
    states
  )

function BasicContMuvParameter!(
  parameter::BasicContMuvParameter,
  setpdf::Union{Function, Void},
  setprior::Union{Function, Void},
  ll::Union{Function, Void},
  lp::Union{Function, Void},
  lt::Union{Function, Void},
  gll::Union{Function, Void},
  glp::Union{Function, Void},
  glt::Union{Function, Void},
  tll::Union{Function, Void},
  tlp::Union{Function, Void},
  tlt::Union{Function, Void},
  dtll::Union{Function, Void},
  dtlp::Union{Function, Void},
  dtlt::Union{Function, Void},
  uptoglt::Union{Function, Void},
  uptotlt::Union{Function, Void},
  uptodtlt::Union{Function, Void}
)
  args = (setpdf, setprior, ll, lp, lt, gll, glp, glt, tll, tlp, tlt, dtll, dtlp, dtlt, uptoglt, uptotlt, uptodtlt)

  # Define setpdf (i = 1) and setprior (i = 2)
  for (i, setter, distribution) in ((1, :setpdf, :pdf), (2, :setprior, :prior))
    setfield!(
      parameter,
      setter,
      if isa(args[i], Function)
        eval(codegen_setfield_basiccontmuvparameter(parameter, distribution, args[i]))
      else
        nothing
      end
    )
  end

  # Define loglikelihood! (i = 3) and gradloglikelihood! (i = 6)
  parameter.loglikelihood! = if isa(args[3], Function)
    eval(codegen_method_basiccontmuvparameter(parameter, args[3]))
  else
    nothing
  end
  parameter.gradloglikelihood! = if isa(args[6], Function)
    eval(codegen_method_basiccontmuvparameter(parameter, args[6]))
  else
    nothing
  end

  # Define logprior! (i = 4) and gradlogprior! (i = 7)
  # ppfield and spfield stand for parameter prior-related field and state prior-related field repsectively
  for (i , ppfield, spfield, f) in ((4, :logprior!, :logprior, logpdf), (7, :gradlogprior!, :gradlogprior, gradlogpdf))
    setfield!(
    parameter,
      ppfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        if (
            isa(parameter.prior, ContinuousMultivariateDistribution) &&
            method_exists(f, (typeof(parameter.prior), Vector{eltype(parameter.prior)}))
          ) ||
          isa(args[2], Function)
          eval(codegen_method_via_distribution_basiccontmuvparameter(parameter, :prior, f, spfield))
        else
          nothing
        end
      end
    )
  end

  # Define logtarget! (i = 5) and gradlogtarget! (i = 8)
  # ptfield, plfield and ppfield stand for parameter target, likelihood and prior-related field respectively
  # stfield, slfield and spfield stand for state target, likelihood and prior-related field respectively
  for (i , ptfield, plfield, ppfield, stfield, slfield, spfield, f) in (
    (5, :logtarget!, :loglikelihood!, :logprior!, :logtarget, :loglikelihood, :logprior, logpdf),
    (8, :gradlogtarget!, :gradloglikelihood!, :gradlogprior!, :gradlogtarget, :gradloglikelihood, :gradlogprior, gradlogpdf)
  )
    setfield!(
      parameter,
      ptfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        if isa(args[i-2], Function) && isa(getfield(parameter, ppfield), Function)
          eval(codegen_method_via_sum_basiccontmuvparameter(parameter, plfield, ppfield, stfield, slfield, spfield))
        elseif (
            isa(parameter.pdf, ContinuousMultivariateDistribution) &&
            method_exists(f, (typeof(parameter.pdf), Vector{eltype(parameter.pdf)}))
          ) ||
          isa(args[1], Function)
          eval(codegen_method_via_distribution_basiccontmuvparameter(parameter, :pdf, f, stfield))
        else
          nothing
        end
      end
    )
  end

  # Define tensorloglikelihood! (i = 9) and dtensorloglikelihood! (i = 12)
  parameter.tensorloglikelihood! = if isa(args[9], Function)
    eval(codegen_method_basiccontmuvparameter(parameter, args[9]))
  else
    nothing
  end
  parameter.dtensorloglikelihood! = if isa(args[12], Function)
    eval(codegen_method_basiccontmuvparameter(parameter, args[12]))
  else
    nothing
  end

  # Define tensorlogprior! (i = 10) and dtensorlogprior! (i = 13)
  parameter.tensorlogprior! = if isa(args[10], Function)
    eval(codegen_method_basiccontmuvparameter(parameter, args[10]))
  else
    nothing
  end
  parameter.dtensorlogprior! = if isa(args[13], Function)
    eval(codegen_method_basiccontmuvparameter(parameter, args[13]))
  else
    nothing
  end

  # Define tensorlogtarget! (i = 11) and dtensorlogtarget! (i = 14)
  for (i , ptfield, plfield, ppfield, stfield, slfield, spfield) in (
    (
      11,
      :tensorlogtarget!, :tensorloglikelihood!, :tensorlogprior!,
      :tensorlogtarget, :tensorloglikelihood, :tensorlogprior
    ),
    (
      14,
      :dtensorlogtarget!, :dtensorloglikelihood!, :dtensorlogprior!,
      :dtensorlogtarget, :dtensorloglikelihood, :dtensorlogprior
    )
  )
    setfield!(
      parameter,
      ptfield,
      if isa(args[i], Function)
        eval(codegen_method_basiccontmuvparameter(parameter, args[i]))
      else
        if isa(args[i-2], Function) && isa(args[i-1], Function)
          eval(codegen_method_via_sum_basiccontmuvparameter(parameter, plfield, ppfield, stfield, slfield, spfield))
        else
          nothing
        end
      end
    )
  end

  # Define uptogradlogtarget!
  setfield!(
    parameter,
    :uptogradlogtarget!,
    if isa(args[15], Function)
      eval(codegen_method_basiccontmuvparameter(parameter, args[15]))
    else
      if isa(parameter.logtarget!, Function) && isa(parameter.gradlogtarget!, Function)
        eval(codegen_uptomethods_basiccontmuvparameter(parameter, [:logtarget!, :gradlogtarget!]))
      else
        nothing
      end
    end
  )

  # Define uptotensorlogtarget!
  setfield!(
    parameter,
    :uptotensorlogtarget!,
    if isa(args[16], Function)
      eval(codegen_method_basiccontmuvparameter(parameter, args[16]))
    else
      if isa(parameter.logtarget!, Function) &&
        isa(parameter.gradlogtarget!, Function) &&
        isa(parameter.tensorlogtarget!, Function)
        eval(codegen_uptomethods_basiccontmuvparameter(parameter, [:logtarget!, :gradlogtarget!, :tensorlogtarget!]))
      else
        nothing
      end
    end
  )

  # Define uptodtensorlogtarget!
  setfield!(
    parameter,
    :uptodtensorlogtarget!,
    if isa(args[17], Function)
      eval(codegen_method_basiccontmuvparameter(parameter, args[17]))
    else
      if isa(parameter.logtarget!, Function) &&
        isa(parameter.gradlogtarget!, Function) &&
        isa(parameter.tensorlogtarget!, Function) &&
        isa(parameter.dtensorlogtarget!, Function)
        eval(codegen_uptomethods_basiccontmuvparameter(
          parameter, [:logtarget!, :gradlogtarget!, :tensorlogtarget!, :dtensorlogtarget!]
        ))
      else
        nothing
      end
    end
  )
end

function BasicContMuvParameter{S<:VariableState}(
  key::Symbol,
  index::Int=0;
  pdf::Union{ContinuousMultivariateDistribution, Void}=nothing,
  prior::Union{ContinuousMultivariateDistribution, Void}=nothing,
  setpdf::Union{Function, Void}=nothing,
  setprior::Union{Function, Void}=nothing,
  loglikelihood::Union{Function, Void}=nothing,
  logprior::Union{Function, Void}=nothing,
  logtarget::Union{Function, Void}=nothing,
  gradloglikelihood::Union{Function, Void}=nothing,
  gradlogprior::Union{Function, Void}=nothing,
  gradlogtarget::Union{Function, Void}=nothing,
  tensorloglikelihood::Union{Function, Void}=nothing,
  tensorlogprior::Union{Function, Void}=nothing,
  tensorlogtarget::Union{Function, Void}=nothing,
  dtensorloglikelihood::Union{Function, Void}=nothing,
  dtensorlogprior::Union{Function, Void}=nothing,
  dtensorlogtarget::Union{Function, Void}=nothing,
  uptogradlogtarget::Union{Function, Void}=nothing,
  uptotensorlogtarget::Union{Function, Void}=nothing,
  uptodtensorlogtarget::Union{Function, Void}=nothing,
  states::Vector{S}=VariableState[]
)
  parameter = BasicContMuvParameter(key, index, pdf, prior, fill(nothing, 17)..., states)

  BasicContMuvParameter!(
    parameter,
    setpdf,
    setprior,
    loglikelihood,
    logprior,
    logtarget,
    gradloglikelihood,
    gradlogprior,
    gradlogtarget,
    tensorloglikelihood,
    tensorlogprior,
    tensorlogtarget,
    dtensorloglikelihood,
    dtensorlogprior,
    dtensorlogtarget,
    uptogradlogtarget,
    uptotensorlogtarget,
    uptodtensorlogtarget
  )

  parameter
end

function BasicContMuvParameter(
  key::Vector{Symbol},
  index::Int;
  pdf::Union{ContinuousMultivariateDistribution, Void}=nothing,
  prior::Union{ContinuousMultivariateDistribution, Void}=nothing,
  setpdf::Union{Function, Void}=nothing,
  setprior::Union{Function, Void}=nothing,
  loglikelihood::Union{Function, Void}=nothing,
  logprior::Union{Function, Void}=nothing,
  logtarget::Union{Function, Void}=nothing,
  gradloglikelihood::Union{Function, Void}=nothing,
  gradlogprior::Union{Function, Void}=nothing,
  gradlogtarget::Union{Function, Void}=nothing,
  tensorloglikelihood::Union{Function, Void}=nothing,
  tensorlogprior::Union{Function, Void}=nothing,
  tensorlogtarget::Union{Function, Void}=nothing,
  dtensorloglikelihood::Union{Function, Void}=nothing,
  dtensorlogprior::Union{Function, Void}=nothing,
  dtensorlogtarget::Union{Function, Void}=nothing,
  uptogradlogtarget::Union{Function, Void}=nothing,
  uptotensorlogtarget::Union{Function, Void}=nothing,
  uptodtensorlogtarget::Union{Function, Void}=nothing,
  nkeys::Int=length(key),
  vfarg::Bool=false
)
  outargs = Array(Union{Function, Void}, 17)

  inargs = (
    setpdf,
    setprior,
    loglikelihood,
    logprior,
    logtarget,
    gradloglikelihood,
    gradlogprior,
    gradlogtarget,
    tensorloglikelihood,
    tensorlogprior,
    tensorlogtarget,
    dtensorloglikelihood,
    dtensorlogprior,
    dtensorlogtarget,
    uptogradlogtarget,
    uptotensorlogtarget,
    uptodtensorlogtarget
  )

  fnames = Array(Any, 17)
  fnames[1:2] = fill(Symbol[], 2)
  fnames[3:14] = [Symbol[f] for f in fieldnames(BasicContMuvParameterState)[2:13]]
  for i in 1:3
    fnames[14+i] = fnames[5:3:(5+i*3)]
  end

  for i in 1:17
    if inargs[i] == nothing
      outargs[i] = nothing
    elseif isa(inargs[i], Function)
      outargs[i] = eval(codegen_internal_variable_method(inargs[i], fnames[i], nkeys, vfarg))
    end
  end

  BasicContMuvParameter(
    key[index],
    index,
    pdf=pdf,
    prior=prior,
    setpdf=outargs[1],
    setprior=outargs[2],
    loglikelihood=outargs[3],
    logprior=outargs[4],
    logtarget=outargs[5],
    gradloglikelihood=outargs[6],
    gradlogprior=outargs[7],
    gradlogtarget=outargs[8],
    tensorloglikelihood=outargs[9],
    tensorlogprior=outargs[10],
    tensorlogtarget=outargs[11],
    dtensorloglikelihood=outargs[12],
    dtensorlogprior=outargs[13],
    dtensorlogtarget=outargs[14],
    uptogradlogtarget=outargs[15],
    uptotensorlogtarget=outargs[16],
    uptodtensorlogtarget=outargs[17],
    states=VariableState[]
  )
end

function basiccontmuvparameter_via_fad{S<:VariableState}(
  key::Vector{Symbol},
  index::Int,
  loglikelihood::Union{Function, Void},
  logprior::Union{Function, Void},
  logtarget::Union{Function, Void};
  pdf::Union{ContinuousMultivariateDistribution, Void}=nothing,
  prior::Union{ContinuousMultivariateDistribution, Void}=nothing,
  setpdf::Union{Function, Void}=nothing,
  setprior::Union{Function, Void}=nothing,
  states::Vector{S}=VariableState[],
  fstatesarg::Bool=true,
  order::Int=1,
  chunksize::Int=0
)
  @assert 1 <= order <= 3 "Derivative order must be 1 or 2 or 3, got $order"

  parameter = BasicContMuvParameter(key[index], index, pdf, prior, fill(nothing, 17)..., states)

  outargs = Union{Function, Void}[nothing for i in 1:17]

  fnames = Array(Any, 17)
  fnames[1:2] = fill(Symbol[], 2)
  fnames[3:14] = [Symbol[f] for f in fieldnames(BasicContMuvParameterState)[2:13]]
  for i in 1:3
    fnames[14+i] = fnames[5:3:(5+i*3)]
  end

  nkeys = fstatesarg ? length(key) : 0

  for (i, f) in ((1, setpdf), (2, setprior))
    if isa(f, Function)
      outargs[i] = eval(codegen_internal_variable_method(f, fnames[i], nkeys, false))
    end
  end

  for (i, f) in ((3, loglikelihood), (4, logprior), (5, logtarget))
    if isa(f, Function)
      outargs[i] = eval(codegen_internal_variable_method(f, fnames[i], nkeys, false))
      if order >= 1
        outargs[i+3] = eval(codegen_internal_variable_method(
          ForwardDiff.gradient(fstatesarg == true ? eval(codegen_internal_fad_closure(parameter, f, nkeys)) : f),
          fnames[i+3],
          0
        ))
      end

      # if order >= 2
      # end

      # if order == 3
      # end
    else
      outargs[i] = nothing
    end
  end

  BasicContMuvParameter!(parameter, outargs...)

  parameter
end

function codegen_setfield_basiccontmuvparameter(parameter::BasicContMuvParameter, field::Symbol, f::Function)
  @gensym codegen_setfield_basiccontmuvparameter
  quote
    function $codegen_setfield_basiccontmuvparameter(_state::BasicContMuvParameterState)
      setfield!($(parameter), $(QuoteNode(field)), $(f)(_state, $(parameter).states))
    end
  end
end

function codegen_method_basiccontmuvparameter(parameter::BasicContMuvParameter, f::Function)
  @gensym codegen_method_basiccontmuvparameter
  quote
    function $codegen_method_basiccontmuvparameter(_state::BasicContMuvParameterState)
      $(f)(_state, $(parameter).states)
    end
  end
end

function codegen_method_via_distribution_basiccontmuvparameter(
  parameter::BasicContMuvParameter,
  distribution::Symbol,
  f::Function,
  field::Symbol
)
  @gensym codegen_method_via_distribution_basiccontmuvparameter
  quote
    function $codegen_method_via_distribution_basiccontmuvparameter(_state::BasicContMuvParameterState)
      setfield!(_state, $(QuoteNode(field)), $(f)(getfield($(parameter), $(QuoteNode(distribution))), _state.value))
    end
  end
end

function codegen_method_via_sum_basiccontmuvparameter(
  parameter::BasicContMuvParameter,
  plfield::Symbol,
  ppfield::Symbol,
  stfield::Symbol,
  slfield::Symbol,
  spfield::Symbol
)
  body = []

  push!(body, :(getfield($(parameter), $(QuoteNode(plfield)))(_state)))
  push!(body, :(getfield($(parameter), $(QuoteNode(ppfield)))(_state)))
  push!(body, :(setfield!(
    _state,
    $(QuoteNode(stfield)),
    getfield(_state, $(QuoteNode(slfield)))+getfield(_state, $(QuoteNode(spfield)))))
  )

  @gensym codegen_method_via_sum_basiccontmuvparameter

  quote
    function $codegen_method_via_sum_basiccontmuvparameter(_state::BasicContMuvParameterState)
      $(body...)
    end
  end
end

function codegen_uptomethods_basiccontmuvparameter(parameter::BasicContMuvParameter, fields::Vector{Symbol})
  body = []
  local f::Symbol

  for i in 1:length(fields)
    f = fields[i]
    push!(body, :(getfield($(parameter), $(QuoteNode(f)))(_state)))
  end

  @gensym codegen_uptomethods_basiccontmuvparameter

  quote
    function $codegen_uptomethods_basiccontmuvparameter(_state::BasicContMuvParameterState)
      $(body...)
    end
  end
end

function codegen_internal_fad_closure(parameter::BasicContMuvParameter, f::Function, nkeys::Int)
  fstatesarg = [Expr(:ref, :Any, [:($(parameter).states[$i].value) for i in 1:nkeys]...)]

  @gensym internal_fad_closure

  quote
    function $internal_fad_closure(_x::Vector)
      $(f)(_x, $(fstatesarg...))
    end
  end
end

value_support(s::Type{BasicContMuvParameter}) = Continuous
value_support(s::BasicContMuvParameter) = Continuous

variate_form(s::Type{BasicContMuvParameter}) = Multivariate
variate_form(s::BasicContMuvParameter) = Multivariate

default_state{N<:Real}(variable::BasicContMuvParameter, value::Vector{N}, outopts::Dict) =
  BasicContMuvParameterState(
    value,
    [getfield(variable, fieldnames(BasicContMuvParameter)[i]) == nothing ? false : true for i in 10:18],
    (haskey(outopts, :diagnostics) && in(:accept, outopts[:diagnostics])) ? [:accept] : Symbol[]
  )
