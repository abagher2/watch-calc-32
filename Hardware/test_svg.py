svg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 50 50" width="50mm" height="50mm">
    <circle cx="25" cy="25" r="3" fill="gray"/>
    
    <path id="top" d="M 20 25 A 5 5 0 0 1 30 25" fill="none" stroke="red"/>
    <text font-size="2" fill="orange"><textPath href="#top" startOffset="50%" text-anchor="middle">TOP TEXT</textPath></text>
    
    <path id="bottom" d="M 20 25 A 5 5 0 0 0 30 25" fill="none" stroke="blue"/>
    <text font-size="2" fill="cyan"><textPath href="#bottom" startOffset="50%" text-anchor="middle">BOTTOM TEXT</textPath></text>
</svg>'''

with open('test.svg', 'w') as f:
    f.write(svg)
