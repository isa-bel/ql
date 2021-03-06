using Microsoft.CodeAnalysis.CSharp.Syntax;
using Semmle.Extraction.Kinds;

namespace Semmle.Extraction.CSharp.Entities.Expressions
{
    class Conditional : Expression<ConditionalExpressionSyntax>
    {
        Conditional(ExpressionNodeInfo info) : base(info.SetKind(ExprKind.CONDITIONAL)) { }

        public static Expression Create(ExpressionNodeInfo info) => new Conditional(info).TryPopulate();

        protected override void Populate()
        {
            Create(cx, Syntax.Condition, this, 0);
            Create(cx, Syntax.WhenTrue, this, 1);
            Create(cx, Syntax.WhenFalse, this, 2);
        }
    }
}
