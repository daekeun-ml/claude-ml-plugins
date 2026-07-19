---
name: svg-flowchart
description: Generate a dark-theme SVG flowchart for ML/VLM architecture pipelines. Takes a natural-language description of a computation graph (modules, tensor shapes, data flow, annotations) and emits a self-contained SVG file. Handles multi-column layouts (image path / text path / center ops), dashed annotation boxes, legend, gradient flow notes, and arrowhead markers. Use when visualizing model components, forward passes, or experiment pipeline designs.
argument-hint: "<pipeline description or module list>, <output path>"
level: 2
---

<Purpose>
Turn a verbal description of a forward-pass or module pipeline into a publication-quality dark-theme SVG diagram. Removes the manual SVG authoring burden while keeping precise control over layout, color-coding, and annotations.
</Purpose>

<Use_When>
- Explaining a new architecture component to collaborators
- Documenting a forward-pass for a paper figure or README
- Creating a visual aid to verify understanding of a multi-step pipeline
- After asking "can you draw this as a flowchart?"
</Use_When>

<Do_Not_Use_When>
- The user wants a rendered image format (PNG/PDF) — SVG only
- The pipeline has more than ~20 nodes (suggest splitting into sub-diagrams)
</Do_Not_Use_When>

<Design_Conventions>
Color palette (dark background #0f1117):
- Image path boxes   : fill=#1e3a5f  stroke=#3b82f6  text=#93c5fd
- Text path boxes    : fill=#3b1f1f  stroke=#f87171  text=#fca5a5
- Learnable modules  : fill=#2d1b4e  stroke=#a78bfa  text=#c4b5fd
- Computation ops    : fill=#1c2d20  stroke=#34d399  text=#6ee7b7
- Gate / scalar      : fill=#3b1f1f  stroke=#fb923c  text=#fed7aa
- Output / final     : fill=#0f2d1e  stroke=#10b981  text=#6ee7b7
- Tensor shape boxes : fill=#1e293b  stroke=#64748b  text=#cbd5e1
- Annotation boxes   : fill varies   stroke=#475569  text=#94a3b8

Arrow colors match the source box stroke color.
Dashed lines (stroke-dasharray="4,3") for skip/residual connections and annotations.

Font: 'Courier New', monospace
Title: font-size=16, bold, center
Node labels: font-size=11 bold for name, font-size=10 for shape/detail, font-size=9 for sub-notes
</Design_Conventions>

<Layout_Rules>
- Multi-column: left=image path, right=text path, center=cross-ops
- Top-to-bottom flow within each column
- Cross-column connections use diagonal or horizontal lines with matching arrow markers
- Annotation boxes positioned to the side, connected with dashed lines
- Legend box bottom-right, gradient flow box bottom-right below legend
- Canvas width: 900–1100px, height: auto (extend as needed)
- Minimum node height: 44px (simple), 52px (with sub-note), 64px (complex op)
- Vertical spacing between nodes: 28px
</Layout_Rules>

<Steps>
1. Parse the pipeline description:
   - Identify modules/operations in order
   - Classify each as: input, frozen, learnable, computation, output, annotation
   - Note tensor shapes at each step
   - Identify data flow connections (straight, skip, cross-column)

2. Plan the layout:
   - Assign nodes to columns (left / center / right)
   - Compute approximate y-positions top-to-bottom
   - Identify cross-column arrows and their anchor points

3. Emit SVG elements in order:
   a. `<svg>` header with viewBox
   b. Background rect
   c. Title and subtitle text
   d. Node rects + text (per column, top to bottom)
   e. Arrows (straight lines and paths for curves/diagonals)
   f. Annotation boxes with dashed connector lines
   g. Legend box
   h. Gradient flow / parameter count box
   i. `<defs>` with named arrow markers at end

4. Write SVG to the specified output path.

5. Report: file path, canvas size, node count, any layout warnings.
</Steps>

<Tool_Usage>
- Write: emit the SVG file to the requested path
- Read: read existing SVG if user wants to extend/modify an existing diagram
- Bash: open the file in browser for quick preview if requested
</Tool_Usage>

<Output_Format>
Single self-contained `.svg` file. No external dependencies. All styles inline.
Report format after writing:
```
SVG written: <path>
Canvas: <W>×<H>px  |  Nodes: <N>  |  Arrows: <M>
Columns: left(<n> nodes) / center(<n> nodes) / right(<n> nodes)
[Any layout warnings]
```
</Output_Format>

<Examples>
<Good>
User: "Draw the QC-AP pipeline: image→ViT→quantizer→engram table→e_grid, text→LLM hidden→last_token→W_q→q̃, center: q̃·k̃ dot product→row/col softmax→pooling→tile+avg→gate→e_t output. Save to experiments_07/qcap_flowchart.svg"
→ Emits full dark-theme SVG with 3 columns, 18 nodes, legend, gradient flow annotation, quantization bottleneck annotation.
</Good>

<Good>
User: "Draw TC-CA: e_vis(B×64×128) → W_k → K, text hidden → W_q → Q(B×N×P), cross-attention(Q·Kᵀ) → slots(B×N×128) → expand back → gate → e_t += gate×e_enriched"
→ Emits SVG with image-path left column, text-path right column, cross-attention center, N-slot annotation box.
</Good>

<Bad>
"Here is a description of the pipeline in text." — No SVG emitted.
</Bad>
</Examples>

<Final_Checklist>
- [ ] Every node has a name label and tensor shape
- [ ] Learnable params colored purple (#a78bfa)
- [ ] Frozen modules labeled "(frozen)"
- [ ] All arrows have correct markers
- [ ] Dashed lines used for skip/residual/annotation connections
- [ ] Legend present if ≥3 color categories used
- [ ] Gradient flow annotation present if requested
- [ ] SVG is self-contained (no external refs)
- [ ] File written and path reported
</Final_Checklist>
