/**
 * Provides a taint-tracking configuration for reasoning about uncontrolled data in path expression
 * vulnerabilities.
 */
import csharp

module TaintedPath {
  import semmle.code.csharp.controlflow.Guards
  import semmle.code.csharp.dataflow.flowsources.Remote
  import semmle.code.csharp.frameworks.system.IO
  import semmle.code.csharp.frameworks.system.Web
  import semmle.code.csharp.security.Sanitizers

  /**
   * A data flow source for uncontrolled data in path expression vulnerabilities.
   */
  abstract class Source extends DataFlow::Node { }

  /**
   * A data flow sink for uncontrolled data in path expression vulnerabilities.
   */
  abstract class Sink extends DataFlow::ExprNode { }

  /**
   * A sanitizer for uncontrolled data in path expression vulnerabilities.
   */
  abstract class Sanitizer extends DataFlow::ExprNode { }

  /**
   * A taint-tracking configuration for uncontrolled data in path expression vulnerabilities.
   */
  class TaintTrackingConfiguration extends TaintTracking::Configuration {
    TaintTrackingConfiguration() {
      this = "TaintedPath"
    }

    override
    predicate isSource(DataFlow::Node source) {
      source instanceof Source
    }

    override
    predicate isSink(DataFlow::Node sink) {
      sink instanceof Sink
    }

    override
    predicate isSanitizer(DataFlow::Node node) {
      node instanceof Sanitizer
    }
  }

  /** A source of remote user input. */
  class RemoteSource extends Source {
    RemoteSource() {
      this instanceof RemoteFlowSource
    }
  }

  /**
   * A path argument to a `File` method call.
   */
  class FileCreateSink extends Sink {
    FileCreateSink() {
      exists(Method create |
        create = any(SystemIOFileClass f).getAMethod() |
        this.getExpr() = create.getACall().getArgumentForName("path")
      )
    }
  }

  /**
   * A path argument to a `Directory` method call.
   */
  class DirectorySink extends Sink {
    DirectorySink() {
      exists(Method create |
        create = any(SystemIODirectoryClass f).getAMethod() |
        this.getExpr() = create.getACall().getArgumentForName("path")
      )
    }
  }

  /**
   * A path argument to a `FileStream` constructor call.
   */
  class FileStreamSink extends Sink {
    FileStreamSink() {
      exists(ObjectCreation oc |
        oc.getTarget().getDeclaringType() = any(SystemIOFileStreamClass f) |
        this.getExpr() = oc.getArgumentForName("path")
      )
    }
  }

  /**
   * A path argument to a `StreamWriter` constructor call.
   */
  class StreamWriterTaintedPathSink extends Sink {
    StreamWriterTaintedPathSink() {
      exists(ObjectCreation oc |
        oc.getTarget().getDeclaringType() = any(SystemIOStreamWriterClass f) |
        this.getExpr() = oc.getArgumentForName("path")
      )
    }
  }

  /**
   * Holds if this expression is part of a check that is insufficient to prevent path tampering.
   */
  private predicate inWeakCheck(Expr e) {
    // None of these are sufficient to guarantee that a string is safe.
    exists(MethodCall m, Method def | m.getTarget() = def |
      (
        m.getQualifier() = e and (
          def.getName() = "StartsWith" or
          def.getName() = "EndsWith"
        )
      ) or
      (
        m.getArgument(0) = e and
        (
          def.getName() = "IsNullOrEmpty" or
          def.getName() = "IsNullOrWhitespace" or
          def = any(SystemIOFileClass f).getAMethod("Exists") or
          def = any(SystemIODirectoryClass f).getAMethod("Exists")
        )
      )
    ) or
    // Checking against `null` has no bearing on path traversal.
    exists(EqualityOperation b | b.getAnOperand() = e |
      b.getAnOperand() instanceof NullLiteral
    )
  }

  /**
   * A conditional involving the path, that is not considered to be a weak check.
   *
   * A weak check is one that is insufficient to prevent path tampering.
   */
  class PathCheck extends Sanitizer {
    PathCheck() {
      /*
       * This expression is structurally replicated in a dominating guard which is not a "weak" check.
       */
      exists(Expr e |
        this.getExpr().(GuardedExpr).isGuardedBy(_, e, _) and
        not inWeakCheck(e)
      )
    }
  }

  /**
   * A call to `HttpRequest.MapPath` that is considered to sanitize the input.
   */
  class RequestMapPathSanitizer extends Sanitizer {
    RequestMapPathSanitizer() {
      exists(Method m |
        m = any(SystemWebHttpRequestClass request).getAMethod() and
        m.hasName("MapPath") |
        this.getExpr() = m.getACall()
      )
    }
  }

  private class SimpleTypeSanitizer extends Sanitizer, SimpleTypeSanitizedExpr { }

  private class GuidSanitizer extends Sanitizer, GuidSanitizedExpr { }
}