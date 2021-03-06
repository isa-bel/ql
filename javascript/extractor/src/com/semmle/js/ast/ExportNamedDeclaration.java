package com.semmle.js.ast;

import java.util.List;

/**
 * A named export declaration, which can be of one of the following forms:
 *
 * <ul>
 * <li><code>export var x = 23;</code></li>
 * <li><code>export { x, y } from 'foo';</code></li>
 * <li><code>export { x, y };</code></li>
 * </ul>
 */
public class ExportNamedDeclaration extends ExportDeclaration {
	private final Statement declaration;
	private final List<ExportSpecifier> specifiers;
	private final Literal source;

	public ExportNamedDeclaration(SourceLocation loc, Statement declaration, List<ExportSpecifier> specifiers, Literal source) {
		super("ExportNamedDeclaration", loc);
		this.declaration = declaration;
		this.specifiers = specifiers;
		this.source = source;
	}

	public Statement getDeclaration() {
		return declaration;
	}

	public boolean hasDeclaration() {
		return declaration != null;
	}

	public List<ExportSpecifier> getSpecifiers() {
		return specifiers;
	}

	public Literal getSource() {
		return source;
	}

	public boolean hasSource() {
		return source != null;
	}

	@Override
	public <C, R> R accept(Visitor<C, R> v, C c) {
		return v.visit(this, c);
	}
}
