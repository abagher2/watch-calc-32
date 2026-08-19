module.exports = {
  params: {
    designator: 'Disp',
    side: 'F',
    VCC: {type: 'net', value: 'VCC'},
    GND: {type: 'net', value: 'GND'},
    DIN: {type: 'net', value: 'MOSI'},
    CLK: {type: 'net', value: 'SCK'},
    CS: {type: 'net', value: 'CS'},
    DC: {type: 'net', value: 'DC'},
    RST: {type: 'net', value: 'RST'},
    BUSY: {type: 'net', value: 'BUSY'}
  },
  body: p => {
    return `
      (module EINK (layer F.Cu) (tedit 5E1ADACE)
        ${p.at /* position */}
        (fp_text reference "${p.ref}" (at 0 -2.54) (layer F.SilkS) (effects (font (size 1 1) (thickness 0.15))))
        (pad 1 thru_hole rect (at 0 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.VCC.str})
        (pad 2 thru_hole circle (at 2.54 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.GND.str})
        (pad 3 thru_hole circle (at 5.08 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.DIN.str})
        (pad 4 thru_hole circle (at 7.62 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.CLK.str})
        (pad 5 thru_hole circle (at 10.16 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.CS.str})
        (pad 6 thru_hole circle (at 12.7 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.DC.str})
        (pad 7 thru_hole circle (at 15.24 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.RST.str})
        (pad 8 thru_hole circle (at 17.78 0 ${p.rot}) (size 1.7 1.7) (drill 1.0) (layers *.Cu *.Mask) ${p.BUSY.str})
      )
    `
  }
}
