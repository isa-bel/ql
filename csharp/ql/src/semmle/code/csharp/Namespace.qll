/** Provides classes for namespaces. */

import Element
import Type
private import dotnet

/**
 * A type container. Either a namespace (`Namespace`) or a type (`Type`).
 */
class TypeContainer extends DotNet::NamedElement, Element, @type_container { }

/**
 * A namespace, for example
 *
 * ```
 * namespace System.IO {
 *   ...
 * }
 * ```
 */
class Namespace extends DotNet::Namespace, TypeContainer, @namespace {
  /** Gets the simple name of this namespace, for example `IO` in `System.IO`. */
  override string getName() { namespaces(this, result) }

  override Namespace getParent() { result = this.getParentNamespace() }

  override Namespace getParentNamespace() { parent_namespace(this, result) }

  override Namespace getAChildNamespace() { parent_namespace(result, this) }

  override TypeContainer getChild(int i) {
    i = 0 and
    parent_namespace(result, this)
  }

  /**
   * Gets a type directly declared in this namespace, if any.
   * For example, the class `File` in
   *
   * ```
   * namespace System.IO {
   *   public class File { ... }
   * }
   * ```
   */
  ValueOrRefType getATypeDeclaration() { parent_namespace(result, this) }

  /**
   * Gets a class directly declared in this namespace, if any.
   * For example, the class `File` in
   *
   * ```
   * namespace System.IO {
   *   public class File { ... }
   * }
   * ```
   */
  Class getAClass() { result = this.getATypeDeclaration() }

  /**
   * Gets an interface directly declared in this namespace, if any.
   * For example, the interface `IEnumerable` in
   *
   * ```
   * namespace System.Collections {
   *   public interface IEnumerable { ... }
   * }
   * ```
   */
  Interface getAnInterface() { result = this.getATypeDeclaration() }

  /**
   * Gets a struct directly declared in this namespace, if any.
   * For example, the struct `Timespan` in
   *
   * ```
   * namespace System {
   *   public struct Timespan { ... }
   * }
   * ```
   */
  Struct getAStruct() { result = this.getATypeDeclaration() }

  /**
   * Gets an enum directly declared in this namespace, if any.
   * For example, the enum `DayOfWeek` in
   *
   * ```
   * namespace System {
   *   public enum DayOfWeek { ... }
   * }
   * ```
   */
  Enum getAnEnum() { result = this.getATypeDeclaration() }

  /**
   * Gets a delegate directly declared in this namespace, if any.
   * For example, the delegate `AsyncCallback` in
   *
   * ```
   * namespace System {
   *   public delegate void AsyncCallback(IAsyncResult ar);
   * }
   * ```
   */
  DelegateType getADelegate() { result = this.getATypeDeclaration() }

  override predicate fromSource() {
    exists(ValueOrRefType t | t.getNamespace() = this and t.fromSource()) or
    exists(Namespace n | n.getParentNamespace() = this and n.fromSource())
  }

  override predicate fromLibrary() { not this.fromSource() }

  /** Gets a declaration of this namespace, if any. */
  NamespaceDeclaration getADeclaration() { result.getNamespace() = this }

  override Location getALocation() {
    result = this.getADeclaration().getALocation()
  }
}

/**
 * The global namespace. This is the root of all namespaces.
 */
class GlobalNamespace extends Namespace {

  GlobalNamespace() { this.hasName("") }
}

/**
 * An explicit namespace declaration in a source file. For example:
 *
 * ```
 * namespace N1.N2 {
 *   ...
 * }
 * ```
 */
class NamespaceDeclaration extends Element, @namespace_declaration {

  /**
   * Gets the declared namespace, for example `N1.N2` in
   *
   * ```
   * namespace N1.N2 {
   *   ...
   * }
   * ```
   */
  Namespace getNamespace() { namespace_declarations(this,result) }

  /**
   * Gets the parent namespace declaration, if any. In the following example,
   * the namespace declaration `namespace N2` on line 2 has parent namespace
   * declaration `namespace N1` on line 1, but `namespace N1` on line 1 and
   * `namespace N1.N2` on line 7 do not have parent namespace declarations.
   *
   * ```
   * namespace N1 {
   *   namespace N2 {
   *     ...
   *   }
   * }
   *
   * namespace N1.N2 {
   *   ...
   * }
   * ```
   */
  NamespaceDeclaration getParentNamespaceDeclaration() { parent_namespace_declaration(this,result) }

  /**
   * Gets a child namespace declaration, if any. In the following example,
   * `namespace N2` on line 2 is a child namespace declaration of
   * `namespace N1` on line 1.
   *
   * ```
   * namespace N1 {
   *   namespace N2 {
   *     ...
   *   }
   * }
   * ```
    */
  NamespaceDeclaration getAChildNamespaceDeclaration() { parent_namespace_declaration(result,this) }

  /**
   * Gets a type directly declared within this namespace declaration.
   * For example, class `C` in
   *
   * ```
   * namespace N {
   *   class C { ... }
   * }
   * ```
   */
  ValueOrRefType getATypeDeclaration() { parent_namespace_declaration(result, this) }

  override Location getALocation() { namespace_declaration_location(this, result) }

  override string toString() { result = "namespace ... { ... }" }
}
