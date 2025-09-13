<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Vaga extends Model
{
    use HasFactory;

    protected $table = 'vagas';

    protected $fillable = [
        'titulo',
        'tipo',     // CLT | PJ | Freelancer
        'status',   // ativa | pausada
    ];

    public function candidatos()
    {
        return $this->belongsToMany(Candidato::class, 'candidato_vaga')->withTimestamps();
    }
}
