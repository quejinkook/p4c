/*
Copyright 2013-present Barefoot Networks, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#ifndef MIDEND_LOCAL_COPYPROP_H_
#define MIDEND_LOCAL_COPYPROP_H_

#include "ir/ir.h"
#include "frontends/p4/typeChecking/typeChecker.h"
#include "frontends/common/resolveReferences/referenceMap.h"

namespace P4 {

/**
Local copy propagation and dead code elimination within a single pass.
This pass is designed to be run after all declarations have received unique
internal names.  This is important because the locals map uses only the
declaration name, and not the full path.

@pre
Requires expression types be stored inline in the expression
(obtained by running Typechecking(updateProgram = true)).

Requires that all declaration names be globally unique
(obtained by running UniqueNames).

Requires that all variable declarations are at the top-level control scope
(obtained using MoveDeclarations).
 */
class DoLocalCopyPropagation : public ControlFlowVisitor, Transform, P4WriteContext {
    bool                        working = false;
    struct VarInfo {
        bool                    local = false;
        bool                    live = false;
        const IR::Expression    *val = nullptr;
    };
    struct TableInfo {
        std::set<cstring>       keyreads, actions;
        int                                             apply_count = 0;
        std::map<cstring, const IR::Expression *>       key_remap;
    };
    struct FuncInfo {
        std::set<cstring>       reads, writes;
    };
    std::map<cstring, VarInfo>          available;
    std::map<cstring, TableInfo>        &tables;
    std::map<cstring, FuncInfo>         &actions;
    std::map<cstring, FuncInfo>         &methods;
    TableInfo                           *inferForTable = nullptr;
    FuncInfo                            *inferForFunc = nullptr;
    bool                                need_key_rewrite = false;
    DoLocalCopyPropagation *clone() const override { return new DoLocalCopyPropagation(*this); }
    void flow_merge(Visitor &) override;
    void dropValuesUsing(cstring);

    void visit_local_decl(const IR::Declaration_Variable *);
    const IR::Node *postorder(IR::Declaration_Variable *) override;
    const IR::Expression *postorder(IR::PathExpression *) override;
    IR::AssignmentStatement *preorder(IR::AssignmentStatement *) override;
    IR::AssignmentStatement *postorder(IR::AssignmentStatement *) override;
    IR::MethodCallExpression *postorder(IR::MethodCallExpression *) override;
    IR::P4Action *preorder(IR::P4Action *) override;
    IR::P4Action *postorder(IR::P4Action *) override;
    IR::Function *preorder(IR::Function *) override;
    IR::Function *postorder(IR::Function *) override;
    IR::P4Control *preorder(IR::P4Control *) override;
    void apply_table(TableInfo *tbl);
    void apply_function(FuncInfo *tbl);
    IR::P4Table *preorder(IR::P4Table *) override;
    IR::P4Table *postorder(IR::P4Table *) override;
    class ElimDead;
    class RewriteTableKeys;

    DoLocalCopyPropagation(const DoLocalCopyPropagation &) = default;

 public:
    DoLocalCopyPropagation() : tables(*new std::map<cstring, TableInfo>),
                               actions(*new std::map<cstring, FuncInfo>),
                               methods(*new std::map<cstring, FuncInfo>)
    { visitDagOnce = false; setName("DoLocalCopyPropagation"); }
};

class LocalCopyPropagation : public PassManager {
 public:
    LocalCopyPropagation(ReferenceMap* refMap, TypeMap* typeMap) {
        passes.push_back(new TypeChecking(refMap, typeMap, true));
        passes.push_back(new DoLocalCopyPropagation);
        setName("LocalCopyPropagation");
    }
};

}  // namespace P4

#endif /* MIDEND_LOCAL_COPYPROP_H_ */
